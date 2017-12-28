#!/usr/bin/env python

import sys
import subprocess

def compress(output_filename):
    "compress"

    cmd = [
        "tar",
        "--exclude", ".DS_Store",
        "--exclude", "./setup/config/*.template.sh",
        "-cvzf", output_filename,
        "./setup"
    ]

    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()

    return stdout, stderr, process.returncode


def main():
    "main function"
    if len(sys.argv) < 2:
	print "USAGE: compress.py pipeline_name"
        exit()

    pipeline_name = sys.argv[1]
    pipeline_version = sys.argv[2]

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
