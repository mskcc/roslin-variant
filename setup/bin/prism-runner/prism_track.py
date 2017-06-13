#!/usr/bin/env python

import os
import re
import uuid
import subprocess
import json
import datetime
from dateutil.parser import parse
import pytz
import redis
import zlib
import base64
import time


DOC_VERSION = "0.0.1"
DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S %Z%z"


def parse_effective_resource_requirement_string(input):

    # fixme: pre-compile regex

    memory = None
    match = re.search(r'mem=(.*?)[,\]]', input)
    if match:
        memory = match.group(1)

    cores = None
    match = re.search(r'iounits=(.*?)\]', input)
    if match:
        cores = match.group(1)

    return memory, cores


def parse_execution_host_string(input):

    if input == '-':
        return 1, "Unknown"

    # fixme: pre-compile regex

    num = None
    host = None
    match = re.search(r'^((\d+)\*)?(.*)$', input)
    if match:
        num = 1 if match.group(2) is None else match.group(2)
        host = match.group(3)
    else:
        num = 1
        host = "Unknown"

    return int(num), host


def parse_lsf_project_name_string(input):

    # fixme: pre-compile regex

    cmo_project_id = None
    job_uuid = None
    match = re.search(r'^(Proj_.*?):([a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12})$', input)
    if match:
        cmo_project_id = match.group(1)
        job_uuid = match.group(2)

    return cmo_project_id, job_uuid


def parse_date_to_utc(input):

    if input == '-':
        return None

    # datetime without timezone info
    naive_dt = parse(input)

    local = pytz.timezone("US/Eastern")
    local_dt = local.localize(naive_dt, is_dst=None)

    utc_dt = local_dt.astimezone(pytz.utc)

    return utc_dt.strftime(DATETIME_FORMAT)


def parse_run_time_string(input):

    # fixme: pre-compile regex
    match = re.search(r'^(\d+) second\(s\)$', input)
    if match:
        return match.group(1)
    else:
        return None


def get_current_utc_datetime():
    "return the current UTC date/time"

    utc_dt = datetime.datetime.utcnow()

    utc_dt = pytz.timezone("UTC").localize(utc_dt, is_dst=None)

    return utc_dt.strftime(DATETIME_FORMAT)


def get_stdouterr_log_path(lsf_job_id):

    bjobs = [
        "bjobs",
        "-o", "exec_cwd output_file error_file delimiter='\t'",
        "-noheader",
        lsf_job_id
    ]

    process = subprocess.Popen(bjobs, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    line = process.stdout.read().rstrip("\n")

    if line:
        work_dir, stdout_log, stderr_log = line.split('\t')
        if work_dir == "-":
            return None
        return os.path.join(work_dir, stdout_log), os.path.join(work_dir, stderr_log)
    else:
        return None


def get_cwltoil_log_path_jobstore_id(stderr_log_path):

    cwltoil_log_path = None
    jobstore_id = None

    # 1-indexed
    line_num = 0

    # make sure lazy loading because log file can be huge
    try:
        with open(stderr_log_path, "rt") as flog:
            for line in flog:
                line_num += 1

                # fixme: pre-compile regex

                # DEBUG:toil.jobStores.fileJobStore:Path to job store directory is '/ifs/work/chunj/prism-proto/prism/tmp/jobstore-6f22c374-4b93-11e7-a203-fc15b424eb90'.
                match = re.search(r"^DEBUG:toil.jobStores.fileJobStore:Path to job store directory is '.*?/jobstore-([a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12})'.$", line)
                if match:
                    jobstore_id = match.group(1)

                # INFO:toil.lib.bioio:Logging to file
                # '/ifs/work/chunj/prism-proto/ifs/prism/inputs/chunj/examples/_tracking_test/5dff7de4/5dff7de4-4b93-11e7-8c71-8cdcd4013cd4/outputs/log/cwltoil.log'.
                match = re.search(r"INFO:toil.lib.bioio:Logging to file '(.*?)'.", line)
                if match:
                    cwltoil_log_path = match.group(1)

                # exit if both path found or line number > 20
                if (jobstore_id and cwltoil_log_path) or line_num > 20:
                    break

    except Exception:
        # file not found if already deleted
        pass

    return cwltoil_log_path, jobstore_id


def get_final_output_metadata(stdout_log_path):

    try:
        with open(stdout_log_path, "rt") as fstdout:
            data = fstdout.read()
            match = re.search(
                "---> PRISM JOB UUID = .*?\n(.*?)<--- PRISM JOB UUID", data, re.DOTALL)

            if match:
                output_metadata = match.group(1).strip()
                if not output_metadata:
                    return None
                return json.loads(output_metadata)
            else:
                return None

    except Exception:
        # file not found if already deleted
        pass


def call_make_runprofile(job_uuid, inputs_yaml_path):

    cmd = [
        "prism_make_runprofile",
        "--job_uuid", job_uuid,
        "--inputs_yaml_path", inputs_yaml_path
    ]

    # fixme: error handling
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=shell)


def construct_run_results(bjobs_info, already_reported_projs):

    # bjobs = [
    #     "bjobs",
    #     "-P", lsf_project_name,
    #     "-a",
    #     "-o", "jobid proj_name job_name stat submit_time start_time finish_time run_time effective_resreq exec_host delimiter='\t'",
    #     "-noheader"
    # ]

    # process = subprocess.Popen(bjobs, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    # rows = process.stdout.readlines()

    # fff = open('bjobs.txt', "r")
    # rows = fff.readlines()
    # fff.close()

    projects = {}

    rows = bjobs_info.splitlines()

    if len(rows) == 1 and (rows[0] == "No unfinished job found\n" or rows[0] == "No job found\n"):
        return projects

    for row in rows:

        p = row.strip().split('\t')

        lsf_job_id, lsf_proj_name, job_name, status, submit_time, start_time, finish_time, run_time, effective_resreq, exec_host = p

        # only care about roslin launched jobs (i.e. lsf_proj_name = Proj_5088_B:eec50a98-4c5f-11e7-af25-8cdcd4013cd4)
        if lsf_proj_name.startswith == "default":
            continue

        # probably we want to not report these?
        if job_name in ["CWLGather", "CWLScatter", "ResolveIndirect", "CWLWorkflow", "CWLJob"]:
            continue

        # parse lsf project name string
        cmo_project_id, job_uuid = parse_lsf_project_name_string(lsf_proj_name)

        # probably not a job that was launched by Roslin
        if cmo_project_id is None or job_uuid is None:
            continue

        # skip if already reported
        if job_uuid in already_reported_projs:
            continue

        if not job_uuid in projects:
            projects[job_uuid] = {
                "version": DOC_VERSION,
                "pipelineJobId": job_uuid,
                "pipelineJobStoreId": None,
                "projectId": cmo_project_id,
                "labels": [],
                "timestamp": {},
                "status": {},
                "logFile": {},
                "batchSystemJobs": {},
                "outputs": {}
            }

        # this is the leader job
        if job_name == "leader:{}:{}".format(cmo_project_id, job_uuid):
            projects[job_uuid]["timestamp"] = {
                "submitted": parse_date_to_utc(submit_time),
                "started": parse_date_to_utc(start_time),
                "finished": parse_date_to_utc(finish_time),
                "duration": parse_run_time_string(run_time),
                "lastUpdated": get_current_utc_datetime()
            }
            projects[job_uuid]["status"] = status

            # if leader job is done, collect output
            if status == "DONE":
                stdout_log_path, _ = get_stdouterr_log_path(lsf_job_id)

                projects[job_uuid]["outputs"] = get_final_output_metadata(stdout_log_path)

            # find if logFile and jobstore id have not been found
            if projects[job_uuid]["logFile"] is None or projects[job_uuid]["pipelineJobStoreId"] is None:

                _, stderr_log_path = get_stdouterr_log_path(lsf_job_id)

                if stderr_log_path:
                    cwltoil_log_path, jobstore_id = get_cwltoil_log_path_jobstore_id(stderr_log_path)
                    projects[job_uuid]["logFile"] = cwltoil_log_path
                    projects[job_uuid]["pipelineJobStoreId"] = jobstore_id

        # parse effective resource requirement string
        memory, cores = parse_effective_resource_requirement_string(effective_resreq)

        # parse execution host string
        num_of_hosts, host_name = parse_execution_host_string(exec_host)

        # construct batchSystemJobs
        projects[job_uuid]["batchSystemJobs"][lsf_job_id] = {
            "name": job_name,
            "status": status,
            "memory": memory,
            "cores": cores,
            "hosts": {
                host_name: num_of_hosts
            },
            "logFile": None
        }

    return projects


def main():
    "main function"

    # connect to redis
    # fixme: configurable host, port, credentials
    redis_client = redis.StrictRedis(host='pitchfork', port=9006, db=0)

    # unique set of job UUIDs that have been already reported
    already_reported_projs = set()

    while True:

        print "-----"

        # this is essentialy the same as subprocess.Popen("bjobs -u all ...", ...)
        data = redis_client.get('bjobs')

        # base64 decode and uncompress
        bjobs_info = zlib.decompress(base64.b64decode(data))

        projects = construct_run_results(bjobs_info, already_reported_projs)

        for job_uuid in projects:

            prj = projects[job_uuid]

            try:

                print "{}:{} ({} secs) ({})".format(prj["projectId"], job_uuid, prj["timestamp"]["duration"], prj["status"])

                for lsf_job_id in prj["batchSystemJobs"]:
                    lsf_job = prj["batchSystemJobs"][lsf_job_id]
                    if lsf_job["status"] != "DONE":
                        print "  - {} {} ({})".format(lsf_job_id, lsf_job["name"], lsf_job["status"])

                redis_client.publish('roslin-run-results', json.dumps(prj))

                # no more reporting if statu is DONE or EXIT
                if prj["status"] in ["DONE", "EXIT"]:
                    already_reported_projs.add(job_uuid)

            except Exception:
                pass

        # project_pretty_json = json.dumps(projects, indent=4)

        # print project_pretty_json

        time.sleep(30)


if __name__ == "__main__":

    main()
