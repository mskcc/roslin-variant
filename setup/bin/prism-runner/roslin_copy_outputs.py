#!/usr/bin/env python
"copy final output to /ifs/res/pi"

import time
import os
import subprocess
import logging
import argparse
import glob
import shutil

# how many parallel copy do we want to execute per host?
NUM_OF_PARALLEL_PER_HOST = 5

logger = logging.getLogger("roslin_copy_outputs")
logger.setLevel(logging.INFO)

# create a file log handler
log_file_handler = logging.FileHandler('roslin_copy_outputs.log')
log_file_handler.setLevel(logging.INFO)

# create a logging format
log_formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
log_file_handler.setFormatter(log_formatter)

# add the handlers to the logger
logger.addHandler(log_file_handler)


def bjobs(lsf_job_id_list):
    "execute bjobs to get status of each job"

    # supply space-separated IDs all at once to bjobs
    # if all jobs are finished, you will get only one "DONE" because of | sort | uniq
    bjobs_cmdline = "bjobs -o stat -noheader {} | sort | uniq".format(" ".join(str(x) for x in lsf_job_id_list))

    process = subprocess.Popen(bjobs_cmdline, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
    output = process.stdout.read()

    return output


def wait_until_done(lsf_job_id_list):
    "wait for all jobs to finish"

    print "Waiting for all jobs to finish..."

    while True:

        # poll bjobs
        results = bjobs(lsf_job_id_list)

        # break out if all DONE
        if results.rstrip() == "DONE":
            break

        time.sleep(5)

    print "DONE."


def bsub(bsubline):
    "execute lsf bsub"

    process = subprocess.Popen(bsubline, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    output = process.stdout.readline()

    # fixme: need better exception handling
    lsf_job_id = int(output.strip().split()[1].strip('<>'))

    return lsf_job_id


def submit_to_lsf(cmo_project_id, job_uuid, job_command, work_dir, job_name):
    "submit roslin-runner to the w node"

    mem = 1
    cpu = NUM_OF_PARALLEL_PER_HOST

    lsf_proj_name = "{}:{}".format(cmo_project_id, job_uuid)
    job_desc = job_name
    sla = "Haystack"

    bsubline = [
        "bsub",
        "-sla", sla,
        "-R", "rusage[mem={}]".format(mem),
        "-n", str(cpu),
        "-P", lsf_proj_name,
        "-J", job_name,
        "-Jd", job_desc,
        "-cwd", work_dir,
        "-o", "roslin_copy_outputs_stdout.txt",
        "-e", "roslin_copy_outputs_stderr.txt",
        job_command
    ]

    lsf_job_id = bsub(bsubline)

    return lsf_proj_name, lsf_job_id


def chunks(l, n):
    "split a list into a n-size chunk"

    # for item i in a range that is a length of l,
    for i in range(0, len(l), n):
        # create an index range for l of n items:
        yield l[i:i + n]


def create_file_list(src_dir, glob_patterns):
    "create a list object that contains all the files to be copied"

    file_list = list()

    # iterate through glob_patterns
    # construct a list that contains all the files to be copied
    for glob_pattern in glob_patterns:
        file_list.extend(glob.glob(os.path.join(src_dir, glob_pattern)))

    # deduplicate
    # fixme: seriously?
    return list(set(file_list))


def create_parallel_cp_commands(file_list, dst_dir):
    "create a parallel cp command"

    cmds = list()

    groups = list(chunks(file_list, NUM_OF_PARALLEL_PER_HOST))

    # e.g. { echo "filename1"; echo "filename2"; } | parallel -j+2 cp {} /dst_dir
    for group in groups:
        cmd = ''
        for filename in group:
            cmd = cmd + 'echo "{}"; '.format(filename)
        cmd = '{ ' + cmd + '} | parallel -j+' + str(NUM_OF_PARALLEL_PER_HOST) + ' cp {} ' + dst_dir

        cmds.append(cmd)

    return cmds


def copy_outputs(cmo_project_id, job_uuid, toil_work_dir, user_out_dir):
    "copy output files in toil work dir to the final destination"

    data = {
        "bam": [
            "outputs/*.bam"
        ],
        "vcf": [
            "outputs/*.vcf",
            "outputs/*.mutect.txt"
        ],
        "maf": [
            "outputs/*.maf"
        ],
        "qc": [
            "outputs/*.asmetrics",
            "outputs/*.hsmetrics",
            "outputs/*.ismetrics*",
            "outputs/*.gcbias*",
            "outputs/*.md_metrics",
            "outputs/*.stats",
            "outputs/*.pdf"
        ],
        "log": [
            "outputs/log/*",
            "stdout.txt",
            "stderr.txt",
            "outputs/output-meta.json"
        ],
        "inputs": [
            "inputs.yaml",
            "{}_sample_grouping.txt".format(cmo_project_id),
            "{}_sample_mapping.txt".format(cmo_project_id),
            "{}_sample_pairing.txt".format(cmo_project_id),
        ]
    }

    # copy project request file to rootdir level
    shutil.copyfile(
        os.path.join(toil_work_dir, "{}_request.txt".format(cmo_project_id)),
        os.path.join(user_out_dir, "{}_request.txt".format(cmo_project_id)),
    )

    # list that will contain all the LSF job IDs
    lsf_job_id_list = list()

    # copy other files using bsub/parallel
    for file_type in data:

        dst_dir = os.path.join(user_out_dir, file_type)
        if not os.path.isdir(dst_dir):
            os.makedirs(dst_dir)

        file_list = create_file_list(toil_work_dir, data[file_type])

        cmds = create_parallel_cp_commands(file_list, dst_dir)

        for num, cmd in enumerate(cmds):

            # bsub parallel cp and store LSF job id
            _, lsf_job_id = submit_to_lsf(cmo_project_id, job_uuid, cmd, toil_work_dir, "roslin_copy_outputs_{}_{}".format(file_type, num))

            # add LSF job id to list object
            lsf_job_id_list.append(lsf_job_id)

    # wait until all issued LSB jobs are finished
    wait_until_done(lsf_job_id_list)


def main():
    "main function"

    parser = argparse.ArgumentParser(description='roslin_copy_outputs')

    parser.add_argument(
        "--cmo-project-id",
        action="store",
        dest="cmo_project_id",
        help="CMO Project ID (e.g. Proj_5088_B)",
        required=True
    )

    parser.add_argument(
        "--job-uuid",
        action="store",
        dest="job_uuid",
        required=True
    )

    parser.add_argument(
        "--toil-work-dir",
        action="store",
        dest="toil_work_dir",
        required=True
    )

    parser.add_argument(
        "--user-out-base-dir",
        action="store",
        dest="user_out_base_dir",
        required=True
    )

    params = parser.parse_args()

    try:

        # construct and cerate the final user output directory
        user_out_dir = os.path.join(params.user_out_base_dir, params.cmo_project_id + "-" + params.job_uuid)
        if not os.path.isdir(user_out_dir):
            os.makedirs(user_out_dir)

        copy_outputs(params.cmo_project_id, params.job_uuid, params.toil_work_dir, user_out_dir)

    except Exception as e:
        logger.error(repr(e))


if __name__ == "__main__":

    main()
