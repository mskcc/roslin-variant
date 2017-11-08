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

    cwl['baseCommand'] = ['cmo_delly', '--version', '0.7.7', '--cmd', 'call']

    del cwl['inputs']['version']
    del cwl['inputs']['cmd']
    cwl['inputs']['normal_bam'] = ruamel.yaml.load("""
type: File
doc: Sorted normal bam
inputBinding:
    prefix: --normal_bam 
secondaryFiles: ['.bai']
""", ruamel.yaml.RoundTripLoader)
    cwl['inputs']['tumor_bam'] = ruamel.yaml.load("""
type: File
doc: Sorted tumor bam
inputBinding:
    prefix: --tumor_bam 
secondaryFiles: ['.bai']
""", ruamel.yaml.RoundTripLoader)
    #-->
    # fixme: until we can auto generate cwl for cmo-facets.doFacets
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
