#!/usr/bin/python
"""postprocess"""

import argparse
import re
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

    cwl['baseCommand'] = ['cmo_vcf2maf', '--version', '1.6.14']
    del cwl['inputs']['version']

    cwl['inputs']['input_vcf']['type'] = ['string', 'File']
    cwl['inputs']['filter_vcf']['type'] = ['null', 'string', 'File']

    # must be specified in input yaml
    del cwl['inputs']['filter_vcf']['default']

    cwl['inputs']['vep_release']['type'] = ['null', 'string']
    cwl['inputs']['vep_release']['default'] = '86'
    cwl['inputs']['max_filter_ac']['type'] = ['null', 'int']
    cwl['inputs']['min_hom_vaf']['type'] = ['null', 'float']
    cwl['inputs']['vep_forks']['type'] = ['null', 'int']
    cwl['inputs']['vep_path']['default'] = '/usr/bin/vep/'
    cwl['inputs']['filter_vcf']['secondaryFiles'] = ['.tbi']

    # use one inside the container by deafult
    cwl['inputs']['custom_enst']['default'] = '/usr/bin/vcf2maf/data/isoform_overrides_at_mskcc'

    cwl['inputs']['buffer_size']['type'] = ['null', 'int']

    write(params.filename_cwl, ruamel.yaml.dump(
        cwl, Dumper=ruamel.yaml.RoundTripDumper))


if __name__ == "__main__":

    main()
