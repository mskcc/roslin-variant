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

    input_bams_type = """
type: array
items: File
"""
    cwl['inputs']['bams']['type'] = ruamel.yaml.load(input_bams_type, ruamel.yaml.RoundTripLoader)
    cwl['inputs']['bams']['secondaryFiles'] = ['^.bai']
    cwl['inputs']['maf']['type'] = 'File'
    cwl['inputs']['n_threads']['type'] = ['null', 'int']
    cwl['inputs']['version']['type'] = ['string']
    cwl['inputs']['version']['default'] = '1.1.9'

    write(params.filename_cwl, ruamel.yaml.dump(
        cwl, Dumper=ruamel.yaml.RoundTripDumper))


if __name__ == "__main__":

    main()
