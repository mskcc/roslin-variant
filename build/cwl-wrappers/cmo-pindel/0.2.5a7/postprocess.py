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

    # replace tab characters and then load
    cwl = ruamel.yaml.load(read(params.filename_cwl).replace('\t', ' '),
                           ruamel.yaml.RoundTripLoader)

    # this CWL is genereated specifically for cmo_pindel 0.2.5a7
    cwl['baseCommand'] = ['cmo_pindel', '--version', '0.2.5a7']
    del cwl['inputs']['version']

    del cwl['inputs']['config_file']
    del cwl['inputs']['config_line']

    cwl['inputs']['include']['type'] = ['null', 'string', 'File']
    cwl['inputs']['exclude']['type'] = ['null', 'string', 'File']

    cwl['inputs']['sample_names'] = ruamel.yaml.load("""
type:
  - "null"
  - type: array
    items: string
inputBinding:
  prefix: --sample_names
  itemSeparator: " "
  separate: True
doc: one line of config file per specification will autogenerate config on fly.
""", ruamel.yaml.RoundTripLoader)

    cwl['inputs']['bams'] = ruamel.yaml.load("""
type:
  - "null"
  - type: array
    items: File
inputBinding:
  prefix: --bam
  itemSeparator: " "
  separate: True
secondaryFiles: ['.bai']
doc: cwltool doesn't copy file inputs if thy dont have input binding it seems...idk.
""", ruamel.yaml.RoundTripLoader)

    #-->
    # fixme: until we can auto generate cwl for GATK
    # set outputs using outputs.yaml
    import os
    cwl['outputs'] = ruamel.yaml.load(
        read(os.path.dirname(params.filename_cwl) + "/outputs.yaml"),
        ruamel.yaml.RoundTripLoader)['outputs']
    #<--

    write(params.filename_cwl, ruamel.yaml.dump(
        cwl, Dumper=ruamel.yaml.RoundTripDumper))


if __name__ == "__main__":

    main()
