#!/usr/bin/env python

import sys
import subprocess
import yaml


def get_config():
    "read config.yaml into the yaml object and return it"

    with open("config.yaml", "r") as file_handle:
        return yaml.load(file_handle.read())


def compress(output_filename):
    "compress"

    cmd = [
        "tar",
        "--exclude", ".DS_Store",
        "--exclude", "./setup/data/assemblies",
#--> fixme
        "--exclude", "./setup/img/abra",
        "--exclude", "./setup/img/basic-filtering",
        "--exclude", "./setup/img/bcftools",
        "--exclude", "./setup/img/bwa",
        "--exclude", "./setup/img/facets",
        "--exclude", "./setup/img/gatk",
        "--exclude", "./setup/img/getbasecountsmultisample",
        "--exclude", "./setup/img/htstools",
        "--exclude", "./setup/img/list2bed",
        "--exclude", "./setup/img/mutect",
        "--exclude", "./setup/img/ngs-filters",
        "--exclude", "./setup/img/picard",
        "--exclude", "./setup/img/pindel",
        "--exclude", "./setup/img/remove-variants",
        "--exclude", "./setup/img/replace-allele-counts",
        "--exclude", "./setup/img/roslin",
        "--exclude", "./setup/img/roslin-qc",
        "--exclude", "./setup/img/seq-cna",
        "--exclude", "./setup/img/trimgalore",
        "--exclude", "./setup/img/vardict",
        "--exclude", "./setup/img/vcf2maf",
        "--exclude", "./setup/img/vep",
#<--
        "-cvzf", output_filename,
        "./setup"
    ]

    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()

    return stdout, stderr, process.returncode


def main():
    "main function"

    config = get_config()
    pipeline_name = config["name"]
    pipeline_version = config["version"]

    output_filename = "roslin-{}-pipeline-v{}.tgz".format(
        pipeline_name,
        pipeline_version
    )

    stdout, stderr, exit_code = compress(output_filename)

    print stdout
    print stderr

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
