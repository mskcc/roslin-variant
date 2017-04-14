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

# --input_file abc
# --input_file def
# --input_file ghi
    input_file = """
- 'null'
- type: array
  items: File
  inputBinding:
    prefix: --input_file
"""
    cwl['inputs']['input_file']['type'] = ruamel.yaml.load(
        input_file, ruamel.yaml.RoundTripLoader)
    del cwl['inputs']['input_file']['inputBinding']

# support multiple knownSites with .idx 
# --knownSites abc.vcf
# --knownSites def.vcf
# --knownSites ghi.vcf
    known_sites = """
type: array
items: File
inputBinding:
  prefix: --knownSites
"""
    cwl['inputs']['knownSites']['type'] = ruamel.yaml.load(
        known_sites, ruamel.yaml.RoundTripLoader)
    del cwl['inputs']['knownSites']['inputBinding']
    cwl['inputs']['knownSites']['secondaryFiles'] = ['.idx']

# --covariate abc
# --covariate def
# --covariate ghi
    covariate = """
type: array
items: string
inputBinding:
  prefix: --covariate
"""
    cwl['inputs']['covariate']['type'] = ruamel.yaml.load(
        covariate, ruamel.yaml.RoundTripLoader)
    del cwl['inputs']['covariate']['inputBinding']

    cwl['inputs']['out']['type'] = ['null', 'string']

    #-->
    # fixme: until we can auto generate cwl for GATK
    # set outputs using outputs.yaml
    import os
    cwl['outputs'] = ruamel.yaml.load(
        read(os.path.dirname(params.filename_cwl) + "/outputs.yaml"),
        ruamel.yaml.RoundTripLoader)['outputs']

    # from : ['cmo_gatk', '-T BaseRecalibrator', '--version 3.3-0']
    # to   : ['cmo_gatk', '-T', 'BaseRecalibrator', '--version', '3.3-0']
    cwl['baseCommand'] = ['cmo_gatk', '-T',
                          'BaseRecalibrator', '--version', '3.3-0']
    #<--

    write(params.filename_cwl, ruamel.yaml.dump(
        cwl, Dumper=ruamel.yaml.RoundTripDumper))


if __name__ == "__main__":

    main()
