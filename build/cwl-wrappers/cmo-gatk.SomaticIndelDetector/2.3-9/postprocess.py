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

    cwl['inputs']['verboseOutput']['type'] = ['null', 'string']
    del cwl['inputs']['version']
    del cwl['inputs']['java_version']

    # workaround: remove redudant quotes by programatically resetting the value here
    cwl['inputs']['filter']['default'] = 'T_COV<10||N_COV<4||T_INDEL_F<0.0001||T_INDEL_CF<0.7'

    #-->
    # fixme: until we can auto generate cwl for GATK
    # set outputs using outputs.yaml
    import os
    cwl['outputs'] = ruamel.yaml.load(
        read(os.path.dirname(params.filename_cwl) + "/outputs.yaml"),
        ruamel.yaml.RoundTripLoader)['outputs']

    # from : ['cmo_gatk']
    # to   : ['cmo_gatk', '-T', 'SomaticIndelDetector', '--version', '2.3-9']
    cwl['baseCommand'] = ['cmo_gatk', '-T', 'SomaticIndelDetector', '--version', '2.3-9']
    #<--

    write(params.filename_cwl, ruamel.yaml.dump(
        cwl, Dumper=ruamel.yaml.RoundTripDumper))


if __name__ == "__main__":

    main()
