#!/usr/bin/env python
"copy final output to /ifs/res/pi"

import time
import os
import sys
import subprocess
import logging
import argparse
import glob
import shutil
import tempfile
import traceback

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

parser.add_argument(
    "--force",
    action="store_true",
    dest="force_overwrite",
    required=False
)
parser.set_defaults(force_overwrite=False)

params = parser.parse_args()

logging_stdout = logging.getLogger().handlers[0]

logger = logging.getLogger("roslin_copy_outputs")
#Set stream level logging    
log_stream_handler = logging.StreamHandler(sys.stdout)
log_stream_handler.setLevel(logging.INFO)
log_stream_formatter = logging.Formatter('[%(message_type)s] - %(message)s')
log_stream_handler.setFormatter(log_stream_formatter)
logger.addHandler(log_stream_handler)
logging.getLogger().removeHandler(logging_stdout)

#Set file level logging
try:
    log_file_handler = logging.FileHandler('roslin_copy_outputs.log')
except IOError as permission_err:
    logger.info("Need permissions to write the log file here:",extra={"message_type":"Permission Error"})
    exc_type, exc_value, exc_tb = sys.exc_info()
    exception_as_string = traceback.format_exception(exc_type,exc_value,exc_tb)
    logger.info("\n"+"".join(exception_as_string),extra={'message_type':"Raw Error"}) 
    sys.exit()   


log_file_handler.setLevel(logging.INFO)    
log_file_formatter = logging.Formatter('[%(message_type)s] - %(message)s')    
log_file_handler.setFormatter(log_file_formatter)    
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

    while True:

        # poll bjobs
        results = bjobs(lsf_job_id_list)

        # break out if all DONE
        if results.rstrip() == "DONE":
            return 0
        elif "EXIT" in results:
            logger.info("Check roslin_copy_outputs_stderr.log",extra={'message_type':"Error"})
            return 1

        time.sleep(10)


def bsub(bsubline):
    "execute lsf bsub"

    process = subprocess.Popen(bsubline, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    output = process.stdout.readline()

    # fixme: need better exception handling
    lsf_job_id = int(output.strip().split()[1].strip('<>'))

    return lsf_job_id


def submit_to_lsf(cmo_project_id, job_uuid, job_command, work_dir, job_name, num_of_parallels_per_host):
    "submit roslin-runner to the w node"

    mem = 1
    cpu = num_of_parallels_per_host

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
        "-o", "roslin_copy_outputs_stdout.log",
        "-e", "roslin_copy_outputs_stderr.log",
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


def create_parallel_cp_commands(file_list, dst_dir, num_of_parallels_per_host):
    "create a parallel cp command"

    cmds = list()
    groups = list()

    num_of_files_per_group = len(file_list) / num_of_parallels_per_host

    if num_of_files_per_group == 0:
        # a single group can cover the entire files
        groups = [file_list]
    else:
        # each group will have x number of files where x = num_of_files_per_group
        groups = list(chunks(file_list, num_of_files_per_group))

    # e.g. { echo "filename1"; echo "filename2"; } | parallel -j+2 cp {} /dst_dir
    for group in groups:

        # skip if there are no files in the group
        if len(group) == 0:
            continue

        # create a temp file to store file names
        with tempfile.NamedTemporaryFile(delete=False) as file_temp:
            for filename in group:
                file_temp.write(filename + "\n")            

            cmd = 'parallel -a ' + file_temp.name + ' -j+' + str(num_of_parallels_per_host) + ' cp {} ' + dst_dir
            cmds.append(cmd)

    return cmds


def copy_outputs(cmo_project_id, job_uuid, toil_work_dir, user_out_dir):
    "copy output files in toil work dir to the final destination"

    # parallels : how many cp do we want to parallelize? (per host)
    # e.g. 5 means 5 cp commands will be parallelized within a single host
    # fixme: externalize this to config.json or something
    data = {
        "bam": {
            "patterns": [
                "outputs/*.bam"
            ],
            "parallels": 5
        },
        "vcf": {
            "patterns": [
                "outputs/*.vcf",
                "outputs/*.mutect.txt"
            ],
            "parallels": 3
        },
        "maf": {
            "patterns": [
                "outputs/*.maf",
                "outputs/*.fillout.maf",
                "outputs/*.ffpe-normal.fillout",
                "outputs/*.curated.fillout"
            ],
            "parallels": 1
        },
        "qc": {
            "patterns": [
                "outputs/*.asmetrics",
                "outputs/*.hsmetrics",
                "outputs/*.ismetrics*",
                "outputs/*.md_metrics",
                "outputs/*.quality_by_cycle_metrics"
                "outputs/*.gcbias*",
                "outputs/*.stats",
                "outputs/*.pdf",
                "outputs/{}_CutAdaptStats.txt".format(cmo_project_id),
                "outputs/{}_DiscordantHomAlleleFractions.txt".format(cmo_project_id),
                "outputs/{}_FingerprintSummary.txt".format(cmo_project_id),
                "outputs/{}_GcBiasMetrics.txt".format(cmo_project_id),
                "outputs/{}_HsMetrics.txt".format(cmo_project_id),
                "outputs/{}_InsertSizeMetrics_Histograms.txt".format(cmo_project_id),
                "outputs/{}_MajorContamination.txt".format(cmo_project_id),
                "outputs/{}_markDuplicatesMetrics.txt".format(cmo_project_id),
                "outputs/{}_MinorContamination.txt".format(cmo_project_id),
                "outputs/{}_post_recal_MeanQualityByCycle.txt".format(cmo_project_id),
                "outputs/{}_pre_recal_MeanQualityByCycle.txt".format(cmo_project_id),
                "outputs/{}_ProjectSummary.txt".format(cmo_project_id),
                "outputs/{}_QC_Report.pdf".format(cmo_project_id),
                "outputs/{}_SampleSummary.txt".format(cmo_project_id),
                "outputs/{}_UnexpectedMatches.txt".format(cmo_project_id),
                "outputs/{}_UnexpectedMismatches.txt".format(cmo_project_id)
            ],
            "parallels": 2
        },
        "log": {
            "patterns": [
                "outputs/log/*",
                "stdout.log",
                "stderr.log",
                "run-profile.json",
                "run-results.json",
                "outputs/output-meta.json",
            ],
            "parallels": 2
        },
        "inputs": {
            "patterns": [
                "inputs.yaml",
                "{}_sample_grouping.txt".format(cmo_project_id),
                "{}_sample_mapping.txt".format(cmo_project_id),
                "{}_sample_pairing.txt".format(cmo_project_id),
            ],
            "parallels": 1
        },
        "facets": {
            "patterns": [
                "outputs/*_hisens.CNCF.png",
                "outputs/*_hisens.cncf.txt",
                "outputs/*_hisens.out",
                "outputs/*_hisens.Rdata",
                "outputs/*_hisens.seg",
                "outputs/*_purity.CNCF.png",
                "outputs/*_purity.cncf.txt",
                "outputs/*_purity.out",
                "outputs/*_purity.Rdata",
                "outputs/*_purity.seg"
            ],
            "parallels": 1
        }
    }

    logger.info("{}:{}:BEGIN".format(cmo_project_id, job_uuid),extra={'message_type':"INFO"})

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

        file_list = create_file_list(toil_work_dir, data[file_type]["patterns"])

        cmds = create_parallel_cp_commands(file_list, dst_dir, data[file_type]["parallels"])

        logger.info("{}:{} ({} jobs in parallel)".format(cmo_project_id, job_uuid, len(cmds)),extra={'message_type':"INFO for {}".format(file_type)})

        for num, cmd in enumerate(cmds):

            # bsub parallel cp and store LSF job id
            _, lsf_job_id = submit_to_lsf(
                cmo_project_id,
                job_uuid,
                cmd,
                toil_work_dir,
                "roslin_copy_outputs_{}_{}_{}".format(file_type, num + 1, len(cmds)),
                data[file_type]["parallels"]
            )            

            logger.info("{}:{}:{} - {}".format(cmo_project_id, job_uuid, lsf_job_id, cmd),extra={'message_type':"Command"})

            # add LSF job id to list object
            lsf_job_id_list.append(lsf_job_id)

    logger.info("{}:{}:WAIT_TILL_FINISH".format(cmo_project_id, job_uuid),extra={'message_type':"INFO"})

    # wait until all issued LSB jobs are finished
    exitcode = wait_until_done(lsf_job_id_list)

    if exitcode == 0:
        logger.info("{}:{}:DONE".format(cmo_project_id, job_uuid),extra={'message_type':"INFO"})
    else:
        logger.info("{}:{}:FAILED".format(cmo_project_id, job_uuid),extra={'message_type':"INFO"})


def main():
    "main function"       

    if not os.access(params.toil_work_dir,os.R_OK):
        logger.info("Need permission to read from {}".format(params.toil_work_dir),extra={'message_type':"Permission Error"})

    if not os.access(params.user_out_base_dir,os.W_OK):
        logger.info("Need permission to write to {}".format(params.user_out_base_dir),extra={'message_type':"Permission Error"})

    try:

        # construct and cerate the final user output directory
        user_out_dir = os.path.join(params.user_out_base_dir, params.cmo_project_id + "." + params.job_uuid)

        copy_ops = True

        if not os.path.isdir(user_out_dir):
            os.makedirs(user_out_dir)
        else:
            copy_ops = params.force_overwrite

        if copy_ops:
            copy_outputs(params.cmo_project_id,params.job_uuid,params.toil_work_dir,user_out_dir)


    except Exception as e:
        logger.info("Error in copying files",extra={'message_type':"Error"})        
        exc_type, exc_value, exc_tb = sys.exc_info()
        exception_as_string = traceback.format_exception(exc_type,exc_value,exc_tb)
        logger.info("\n"+"".join(exception_as_string),extra={'message_type':"Raw Error"})



if __name__ == "__main__":

    main()
