#!/usr/bin/env python3

import sys
import subprocess
import os

script_path = os.path.dirname(os.path.realpath(__file__))
root_dir = os.path.abspath(os.path.join(script_path,os.pardir,os.pardir))

def compress(output_filename):
    "compress"

    setup_dir = os.path.join(root_dir,'setup')
    current_dir = os.getcwd()
    exclude_template = os.path.abspath(os.path.join(setup_dir,'config','*.template.sh'))
    exclude_ds_store = os.path.abspath(os.path.join(root_dir,'.DS_Store'))
    exclude_template_rel = os.path.relpath(exclude_template,current_dir)
    exclude_ds_store_rel = os.path.relpath(exclude_ds_store,current_dir)
    setup_dir_rel = os.path.relpath(setup_dir,current_dir)

    cmd = [
        "tar",
        "--exclude", exclude_ds_store_rel,
        "--exclude", exclude_template_rel,
        "-cvzf", output_filename,
        setup_dir_rel
    ]

    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()

    return stdout, stderr, process.returncode


def main():
    "main function"
    if len(sys.argv) < 2:
        print("USAGE: compress.py pipeline_name")
        exit()

    pipeline_name = sys.argv[1]
    pipeline_version = sys.argv[2]

    output_filename = "roslin-{}-pipeline-v{}.tgz".format(
        pipeline_name,
        pipeline_version
    )

    stdout, stderr, exit_code = compress(output_filename)

    print(stdout)
    print(stderr)

    if exit_code == 0:
        print("Compress finished")
    else:
        print("Compress failed")

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
