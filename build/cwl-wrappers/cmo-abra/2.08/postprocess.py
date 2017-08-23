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

    print params.filename_cwl
    cwl = ruamel.yaml.load(read(params.filename_cwl),
                           ruamel.yaml.RoundTripLoader)

# 1) we're doing this way to preserve the order
#    can't figure out other ways.
# 2) the prefix --in param must be set up this way to have
#    ABRA output --in multiple times
    input_file_type = """
type: array
items: File
"""
    cwl['baseCommand'] = ['cmo_abra', '--version', '2.08']
    cwl['inputs']['working'] = {'type': 'string','doc':'Working directory for intermediate output. Must not already exist','inputBinding':{'prefix':'--working'}}
    cwl['inputs']['in']['type'] = ruamel.yaml.load(input_file_type, ruamel.yaml.RoundTripLoader)
    cwl['inputs']['in']['inputBinding'].insert(0, 'itemSeparator', ',')
    cwl['inputs']['in']['secondaryFiles'] = ['^.bai']
    cwl['inputs']['targets']['type'].insert(1, 'File')
    input_out_type = """
type: array
items: string
"""
    cwl['inputs']['out']['type'] = ruamel.yaml.load(input_out_type, ruamel.yaml.RoundTripLoader)
    cwl['inputs']['out']['inputBinding'].insert(0, 'itemSeparator', ',')
    cwl['inputs']['threads']['default'] = '15'
    del cwl['inputs']['version']
    del cwl['inputs']['java_version']

    write(params.filename_cwl, ruamel.yaml.dump(
        cwl, Dumper=ruamel.yaml.RoundTripDumper))


if __name__ == "__main__":

    main()
