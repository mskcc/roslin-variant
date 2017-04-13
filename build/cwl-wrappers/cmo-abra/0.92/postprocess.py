#!/usr/bin/python
"""postprocess"""

import argparse
import ruamel.yaml


def read(filename):
    """return file contents"""

    with open(filename, 'r') as file_in:
        return file_in.read()


def write(filename, cwl):
    """write to file"""

    with open(filename, 'w') as file_out:
        file_out.write(cwl)


def main():
    """main function"""

    parser = argparse.ArgumentParser(description='postprocess')

    parser.add_argument(
        '-f',
        action="store",
        dest="filename_cwl",
        help='Name of the cwl file',
        required=True
    )

    params = parser.parse_args()

    cwl = ruamel.yaml.load(read(params.filename_cwl),
                           ruamel.yaml.RoundTripLoader)

# we're doing this way to preserve the order
# can't figure out other ways.
    input_file_type = """
type: array
items: File
"""
    cwl['inputs']['in']['type'] = ruamel.yaml.load(input_file_type, ruamel.yaml.RoundTripLoader)
    cwl['inputs']['in']['secondaryFiles'] = ['.bai']
    cwl['inputs']['targets']['type'].insert(1, 'File')
    cwl['inputs']['out']['type'] = 'string[]'
    cwl['inputs']['out']['inputBinding'].insert(0, 'itemSeparator', ',')
    del cwl['inputs']['version']
    del cwl['inputs']['java_version']

    write(params.filename_cwl, ruamel.yaml.dump(
        cwl, Dumper=ruamel.yaml.RoundTripDumper))


if __name__ == "__main__":

    main()
