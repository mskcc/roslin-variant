#!/usr/bin/python
"""post-process of cwl"""

import os.path
import argparse
import datetime
import yaml


def get_requirements(filename):
    """read requirements from file and process it"""

    requirements = ""

    if os.path.exists(filename) is False:
        print "File not found: {}".format(filename)
        exit(1)

    with open(filename, "r") as file_in:
        requirements = file_in.read()

    if requirements:
        requirements = "\n" + requirements + "\n"

    return requirements


def get_metadata(filename, params=None):
    """read metadata from file and process it"""

    metadata = ""

    if os.path.exists(filename) is False:
        print "File not found: {}".format(filename)
        exit(1)

    with open(filename, "r") as file_in:
        metadata = "\n" + file_in.read() + "\n"
        # datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")

    return metadata


def get_cwl(filename):
    """read cwl form file and process it"""

    with open(filename, "r") as file_in:
        cwl = file_in.readlines()

    return cwl


def write_cwl(filename, cwl):
    """write cwl to file"""

    with open(filename, "w") as file_out:
        file_out.write(cwl)


def main():
    """main function"""

    parser = argparse.ArgumentParser(description='postprocess-cwl')

    parser.add_argument(
        '-f',
        action="store",
        dest="filename_cwl",
        help='Name of the cwl file',
        required=True
    )
    parser.add_argument(
        '-v',
        action="store",
        dest="version",
        help='Version of the tool',
        required=True
    )
    parser.add_argument(
        '-r',
        action="store",
        dest="filename_req",
        help='Name of the file that contains the requirements section',
        required=True
    )
    parser.add_argument(
        '-m',
        action="store",
        dest="filename_metadata",
        help='Name of the file that contains metadata',
        required=True
    )

    params = parser.parse_args()

    # read cwl from file
    cwl_contents = get_cwl(params.filename_cwl)

    # get metada
    metadata = get_metadata(params.filename_metadata, params)

    # add metadata
    cwl_contents.insert(1, metadata)

    # get requirements
    requirements = get_requirements(params.filename_req)

    # add requirements section
    cwl_contents.insert(10, requirements)

    # write back to file
    write_cwl(params.filename_cwl, "".join(cwl_contents))


if __name__ == "__main__":

    main()
