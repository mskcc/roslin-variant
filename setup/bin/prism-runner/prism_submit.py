#!/usr/bin/env python

import glob
import subprocess
import argparse
import uuid
import ruamel.yaml
import os
from shutil import copyfile
import redis
import hashlib
import datetime
import pytz
import json
import tarfile
import base64
import time
import re


DOC_VERSION = "0.0.1"
DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S %Z%z"


def bsub(bsubline):
    "execute lsf bsub"

    process = subprocess.Popen(bsubline, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    output = process.stdout.readline()

    # fixme: need better exception handling
    lsf_job_id = int(output.strip().split()[1].strip('<>'))

    return lsf_job_id


def submit_to_lsf(cmo_project_id, job_uuid, work_dir, workflow_name):
    "submit roslin-runner to the w node"

    mem = 1
    cpu = 1
    leader_node = "w01"
    queue_name = "control"

    lsf_proj_name = "{}:{}".format(cmo_project_id, job_uuid)
    job_name = "leader:{}:{}".format(cmo_project_id, job_uuid)
    job_desc = job_name
    output_dir = os.path.join(work_dir, "outputs")
    input_yaml = "inputs.yaml"

    job_command = "prism-runner.sh -w {} -i {} -b lsf -p {} -j {} -o {}".format(
        workflow_name,
        input_yaml,
        cmo_project_id,
        job_uuid,
        output_dir
    )

    bsubline = [
        "bsub",
        "-R", "select[hname={}]".format(leader_node),
        "-q", queue_name,
        "-R", "rusage[mem={}]".format(mem),
        "-n", str(cpu),
        "-P", lsf_proj_name,
        "-J", job_name,
        "-Jd", job_desc,
        "-cwd", work_dir,
        "-oo", "stdout.txt",
        "-eo", "stderr.txt",
        job_command
    ]

    lsf_job_id = bsub(bsubline)

    return lsf_proj_name, lsf_job_id


def read(filename):
    """return file contents"""

    with open(filename, 'r') as file_in:
        return file_in.read()


def write(filename, cwl):
    """write to file"""

    with open(filename, 'w') as file_out:
        file_out.write(cwl)


def set_abra_scratch_directory(input_yaml_template_filename, job_uuid, work_dir):
    "set abra scratch directory"

    # read e.g. input.yaml.template
    input_yaml = ruamel.yaml.load(
        read(input_yaml_template_filename),
        ruamel.yaml.RoundTripLoader
    )

    # set the abra_scratch directory
    input_yaml["abra_scratch"] = "/scratch/prism-abra-{}".format(job_uuid)

    # write back to disk
    write(
        os.path.join(work_dir, "inputs.yaml"),
        ruamel.yaml.dump(input_yaml, Dumper=ruamel.yaml.RoundTripDumper)
    )


# fixme: move to common
def get_current_utc_datetime():
    "return the current UTC date/time"

    utc_dt = datetime.datetime.utcnow()

    utc_dt = pytz.timezone("UTC").localize(utc_dt, is_dst=None)

    return utc_dt.strftime(DATETIME_FORMAT)


def generate_sha1(filename):

    # 64kb chunks
    buf_size = 65536

    sha1 = hashlib.sha1()

    with open(filename, 'rb') as f:
        while True:
            data = f.read(buf_size)
            if not data:
                break
            sha1.update(data)

    return sha1.hexdigest()


def targzip_project_files(cmo_project_id, cmo_project_path):

    files = glob.glob(os.path.join(cmo_project_path, "*"))

    tgz_path = "{}.tgz".format(os.path.join(cmo_project_path, cmo_project_id))
    tar = tarfile.open(tgz_path, "w:gz")
    for filename in files:
        tar.add(filename)
    tar.close()

    with open(tgz_path, "rb") as tgz_file:
        return base64.b64encode(tgz_file.read())


def convert_examples_to_use_abs_path(inputs_yaml_path):
    "convert example inputs.yaml to use absolute path"

    output = []

    # fixme: best way is to look for:
    #   class: File
    #   path: ../abc/def/123.fastq
    with open(inputs_yaml_path, "r") as yaml_file:
        lines = yaml_file.readlines()
        prev_line = ""
        for line in lines:
            line = line.rstrip("\n")
            if "class: File" in prev_line:
                # fixme: pre-compile
                pattern = r"path: (\.\./data/from-module-.*)"
                match = re.search(pattern, line)
                if match:
                    path = os.path.abspath(match.group(1))
                    line = re.sub(pattern, "path: {}".format(path), line)
            output.append(line)
            prev_line = line

    with open(inputs_yaml_path, "w") as yaml_file:
        yaml_file.write("\n".join(output))


def construct_project_metadata(cmo_project_id, cmo_project_path):

    request_file = os.path.abspath(
        os.path.join(cmo_project_path, cmo_project_id + "_request.txt")
    )
    mapping_file = os.path.abspath(
        os.path.join(cmo_project_path, cmo_project_id + "_sample_mapping.txt")
    )
    grouping_file = os.path.abspath(
        os.path.join(cmo_project_path, cmo_project_id + "_sample_grouping.txt")
    )
    pairing_file = os.path.abspath(
        os.path.join(cmo_project_path, cmo_project_id + "_sample_pairing.txt")
    )

    # skip if any of this file is missing
    if not os.path.isfile(request_file) or not os.path.isfile(mapping_file) \
            or not os.path.isfile(grouping_file) or not os.path.isfile(pairing_file):
        return None

    tgz_blob = targzip_project_files(cmo_project_id, cmo_project_path)

    project = {
        "version": DOC_VERSION,
        "projectId": cmo_project_id,
        "dateSubmitted": get_current_utc_datetime(),
        "inputFiles": {
            "blob": tgz_blob,
            "request": {
                "path": request_file,
                "checksum": "sha1$" + generate_sha1(request_file)
            },
            "mapping": {
                "path": mapping_file,
                "checksum": "sha1$" + generate_sha1(mapping_file)
            },
            "grouping": {
                "path": grouping_file,
                "checksum": "sha1$" + generate_sha1(grouping_file)
            },
            "pairing": {
                "path": pairing_file,
                "checksum": "sha1$" + generate_sha1(pairing_file)
            }
        }
    }

    return project


def publish_to_redis(cmo_project_id, cmo_project_path, lsf_proj_name):

    # fixme: wait until leader job shows up in LSF
    data = construct_project_metadata(cmo_project_id, cmo_project_path)

    if not data:
        return

    # connect to redis
    # fixme: configurable host, port, credentials
    redis_client = redis.StrictRedis(host='pitchfork', port=9006, db=0)

    redis_client.publish('roslin-projects', json.dumps(data))


def main():
    "main function"

    parser = argparse.ArgumentParser(description='submit')

    parser.add_argument(
        "--id",
        action="store",
        dest="cmo_project_id",
        help="CMO Project ID (e.g. Proj_5088_B)",
        required=True
    )

    parser.add_argument(
        "--path",
        action="store",
        dest="cmo_project_path",
        help="Path to CMO Project (e.g. /ifs/projects/CMO/Proj_5088_B",
        required=True
    )

    parser.add_argument(
        "--workflow",
        action="store",
        dest="workflow_name",
        help="CWL Workflow name (e.g. module-1-2-3.chunk.cwl)",
        required=True
    )

    params = parser.parse_args()

    # create a new unique job uuid
    job_uuid = str(uuid.uuid1())

    # must be one of the singularity binding points
    work_base_dir = "/ifs/work/chunj/prism-proto/ifs/prism/outputs"
    work_dir = os.path.join(work_base_dir, job_uuid[:8], job_uuid)

    if not os.path.exists(work_dir):
        os.makedirs(work_dir)

    if params.workflow_name in ["module-2.cwl", "module-1-2-3.cwl", "module-1-2-3.chunk.cwl"]:
        # populate the 'abra_scratch' field and copy to work directory
        set_abra_scratch_directory(
            os.path.join(params.cmo_project_path, "inputs.yaml.template"),
            job_uuid,
            work_dir
        )
    else:
        # copy to work directory
        copyfile(
            os.path.join(params.cmo_project_path, "inputs.yaml"),
            os.path.join(work_dir, "inputs.yaml")
        )

    # convert any relative path in inputs.yaml (e.g. path: ../abc)
    # to absolute path (e.g. path: /ifs/abc)
    convert_examples_to_use_abs_path(
        os.path.join(work_dir, "inputs.yaml")
    )

    # submit
    lsf_proj_name, lsf_job_id = submit_to_lsf(
        params.cmo_project_id,
        job_uuid,
        work_dir,
        params.workflow_name
    )

    print lsf_proj_name
    print lsf_job_id
    print work_dir

    # fixme: wait till leader job shows up
    time.sleep(5)

    publish_to_redis(params.cmo_project_id, params.cmo_project_path, lsf_proj_name)


if __name__ == "__main__":

    main()
