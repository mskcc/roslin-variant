#!/usr/bin/env python

import sys
import subprocess
import os

script_path = os.path.dirname(os.path.realpath(__file__))
root_dir = os.path.abspath(os.path.join(script_path,os.pardir,os.pardir))

def compress(output_filename):
    "compress"

    setup_dir = os.path.join(root_dir,'setup')
    exclude_template = os.path.abspath(os.path.join(setup_dir,'config','*.template.sh'))
    exclude_ds_store = os.path.abspath(os.path.join(root_dir,'.DS_Store'))

    cmd = [
        "tar",
        "--exclude", exclude_ds_store,
        "--exclude", exclude_template,
        "-cvzf", output_filename,
        setup_dir
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
