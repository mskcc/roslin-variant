#!/usr/bin/env python

import os
import subprocess
import hashlib
import json
import ruamel.yaml
import argparse
import redis


DOC_VERSION = "0.0.1"


def item(path, version, checksum_method, checksum_value):

    if checksum_method and checksum_value:
        checksum = "{}${}".format(checksum_method, checksum_value)
    else:
        checksum = "n/a"

    return {
        "path": path,
        "version": version,
        "checksum": checksum
    }


def read(filename):
    """return file contents"""

    with open(filename, 'r') as file_in:
        return file_in.read()


def write(filename, cwl):
    """write to file"""

    with open(filename, 'w') as file_out:
        file_out.write(cwl)


def get_references(inputs_yaml_path):
    "get references"

    references = {}

    # read inputs.yaml
    yaml = ruamel.yaml.load(
        read(inputs_yaml_path),
        ruamel.yaml.RoundTripLoader
    )

    if "genome" in yaml:
        references["genome"] = yaml["genome"]

    if "hapmap" in yaml:
        references["hapmap"] = item(
            path=yaml["hapmap"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(yaml["hapmap"]["path"])
        )

    if "dbsnp" in yaml:
        references["dbsnp"] = item(
            path=yaml["dbsnp"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(yaml["dbsnp"]["path"])
        )

    if "indels_1000g" in yaml:
        references["indels_1000g"] = item(
            path=yaml["indels_1000g"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(yaml["indels_1000g"]["path"])
        )

    if "snps_1000g" in yaml:
        references["snps_1000g"] = item(
            path=yaml["snps_1000g"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(yaml["snps_1000g"]["path"])
        )

    if "cosmic" in yaml:
        references["cosmic"] = item(
            path=yaml["cosmic"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(yaml["cosmic"]["path"])
        )

    if "refseq" in yaml:
        references["refseq"] = item(
            path=yaml["refseq"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(yaml["refseq"]["path"])
        )

    return references


# fixme: common
def run(cmd, shell=False, strip_newline=True):
    "run a command"

    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=shell)
    stdout = process.stdout.read()
    if strip_newline:
        stdout = stdout.rstrip("\n")
    return stdout


# fixme: common
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


def get_singularity_info():
    "get singularity info"

    path = os.environ.get("PRISM_SINGULARITY_PATH")

    version = run([path, "--version"])

    sha1 = generate_sha1(path)

    return item(
        path=path,
        version=version,
        checksum_method="sha1",
        checksum_value=sha1
    )


def get_roslin_info():
    "get roslin info"

    # fixme: roslin
    version = os.environ.get("PRISM_VERSION")
    path = os.environ.get("PRISM_BIN_PATH")

    return item(
        path=path,
        version=version,
        checksum_method=None,
        checksum_value=None
    )


def get_cmo_pkg_info():
    "get cmo package info"

    path = run(["which", "cmo_bwa_mem"])
    bin_path = os.environ.get("PRISM_BIN_PATH")
    res_json_path = os.path.join(bin_path, "pipeline/1.0.0/prism_resources.json")

    cmd = 'CMO_RESOURCE_CONFIG="{}" python -c "import cmo; print cmo.__version__"'.format(res_json_path)
    version = run(cmd, True)

    return item(
        path=path,
        version=version,
        checksum_method=None,
        checksum_value=None
    )


def get_cwltoil_info():
    "get cwltoil info"

    path = run(["which", "cwltoil"])

    version = run([path, "--version"])

    sha1 = generate_sha1(path)

    return item(
        path=path,
        version=version,
        checksum_method="sha1",
        checksum_value=sha1
    )


def get_node_info():
    "get node info"

    path = run(["which", "node"])

    version = run([path, "--version"])

    sha1 = generate_sha1(path)

    return item(
        path=path,
        version=version,
        checksum_method="sha1",
        checksum_value=sha1
    )


def make_runprofile(job_uuid, inputs_yaml_path):
    "make run profile"

    run_profile = {

        "version": DOC_VERSION,

        "pipelineJobId": job_uuid,

        "softwareUsed": {

            "roslin": get_roslin_info(),
            "cmo": get_cmo_pkg_info(),
            "singularity": get_singularity_info(),
            "cwltoil": get_cwltoil_info(),
            "node": get_node_info(),

            "bioinformatics": [

            ]
        },

        "references": get_references(inputs_yaml_path)
    }

    return run_profile


def publish_to_redis(job_uuid, run_profile):
    "publish to redis"

    # connect to redis
    # fixme: configurable host, port, credentials
    redis_client = redis.StrictRedis(host='pitchfork', port=9006, db=0)

    json_results = json.dumps(run_profile)

    redis_client.publish('roslin-run-profiles', json_results)
    redis_client.setex(job_uuid, 86400, json_results)


def main():
    "main function"

    parser = argparse.ArgumentParser(description='make_runprofile')

    parser.add_argument(
        "--job_uuid",
        action="store",
        dest="job_uuid",
        required=True
    )

    parser.add_argument(
        "--inputs_yaml_path",
        action="store",
        dest="inputs_yaml_path",
        help="Path to inputs.yaml",
        required=True
    )

    params = parser.parse_args()

    run_profile = make_runprofile(params.job_uuid, params.inputs_yaml_path)

    print json.dumps(run_profile, indent=2)

    publish_to_redis(params.job_uuid, run_profile)


if __name__ == "__main__":

    main()
