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
        "--exclude", "P-00*.fastq.gz",
        "--exclude", "./setup/data/assemblies",
        "-cvzf", output_filename,
        "./setup"
    ]

    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()

    return stdout, stderr, process.returncode


def main():
    "main function"

    config = get_config()
    version = config["version"]

    output_filename = "roslin-v{}.tgz".format(version)

    stdout, stderr, exit_code = compress(output_filename)

    print stdout
    print stderr

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
