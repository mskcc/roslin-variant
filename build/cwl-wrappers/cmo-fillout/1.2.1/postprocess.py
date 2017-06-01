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

    cwl = ruamel.yaml.load(read(params.filename_cwl), ruamel.yaml.RoundTripLoader)

    cwl['baseCommand'] = ['cmo_fillout', '--version', '1.2.1']

    input_bams_type = """
type: array
items: File
"""
    cwl['inputs']['bams']['type'] = ruamel.yaml.load(input_bams_type, ruamel.yaml.RoundTripLoader)
    cwl['inputs']['bams']['secondaryFiles'] = ['^.bai']
    cwl['inputs']['maf']['type'] = 'File'
    cwl['inputs']['n_threads']['type'] = ['null', 'int']
    del cwl['inputs']['version']

    # workaround: cwl doesn't allow "--format"" as an input parameter name
    del cwl['inputs']['format']
    input_output_format = """
type: string
doc: Output format MAF(1) or tab-delimited with VCF based coordinates(2)
inputBinding:
  prefix: --format

"""
    cwl['inputs']['output_format'] = ruamel.yaml.load(input_output_format, ruamel.yaml.RoundTripLoader)

    write(params.filename_cwl, ruamel.yaml.dump(cwl, Dumper=ruamel.yaml.RoundTripDumper))


if __name__ == "__main__":

    main()
