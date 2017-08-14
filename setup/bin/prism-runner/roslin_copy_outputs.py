#!/usr/bin/env python
"copy final output to /ifs/res/pi"

import os
import subprocess
import logging
import argparse
import glob
import shutil


NUM_OF_CHUNKS = 4

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


def bsub(bsubline):
    "execute lsf bsub"

    process = subprocess.Popen(bsubline, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    output = process.stdout.readline()

    # fixme: need better exception handling
    print output
    lsf_job_id = int(output.strip().split()[1].strip('<>'))

    return lsf_job_id


def submit_to_lsf(cmo_project_id, job_uuid, job_command, work_dir, job_name):
    "submit roslin-runner to the w node"

    mem = 1
    cpu = NUM_OF_CHUNKS

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
        job_command
    ]

    print bsubline

    lsf_job_id = bsub(bsubline)

    return lsf_proj_name, lsf_job_id


def chunks(l, n):
    # For item i in a range that is a length of l,
    for i in range(0, len(l), n):
        # Create an index range for l of n items:
        yield l[i:i + n]


def create_file_list(src_dir, glob_patterns):

    file_list = list()

    for glob_pattern in glob_patterns:
        file_list.extend(glob.glob(os.path.join(src_dir, glob_pattern)))

    # fixme: seriously?
    return list(set(file_list))


def create_lsf_parallel_cp_commands(file_list, dst_dir):

    cmds = list()

    groups = list(chunks(file_list, NUM_OF_CHUNKS))

    for group in groups:
        cmd = ''
        for filename in group:
            cmd = cmd + 'echo "{}"; '.format(filename)
        cmd = '{ ' + cmd + '} | parallel -j+' + str(NUM_OF_CHUNKS) + ' cp {} ' + dst_dir

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

    # copy other files using bsub/parallel
    for file_type in data:

        if file_type == "bam":
            continue

        dst_dir = os.path.join(user_out_dir, file_type)
        if not os.path.isdir(dst_dir):
            os.makedirs(dst_dir)

        file_list = create_file_list(toil_work_dir, data[file_type])

        cmds = create_lsf_parallel_cp_commands(file_list, dst_dir)

        for cmd in cmds:
            submit_to_lsf(cmo_project_id, job_uuid, cmd, toil_work_dir, "roslin_copy_outputs_{}".format(file_type))


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
        user_out_dir = os.path.join(params.user_out_base_dir, params.cmo_project_id)
        if not os.path.isdir(user_out_dir):
            os.makedirs(user_out_dir)

        copy_outputs(params.cmo_project_id, params.job_uuid, params.toil_work_dir, user_out_dir)

    except Exception as e:
        logger.error(repr(e))


if __name__ == "__main__":

    main()
