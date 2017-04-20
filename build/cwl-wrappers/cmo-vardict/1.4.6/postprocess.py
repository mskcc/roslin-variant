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

    # replace tab characters
    cwl_str = read(params.filename_cwl).replace('\t', ' ')

    # cwl(toil) unable to handle numeric parameters
    cwl_str = re.sub(r"3:$", "three:", cwl_str, flags=re.MULTILINE)

    # load
    cwl = ruamel.yaml.load(cwl_str, ruamel.yaml.RoundTripLoader)

    # this CWL is genereated specifically for cmo_vardict 1.4.6
    cwl['baseCommand'] = ['cmo_vardict', '--version', '1.4.6']
    del cwl['inputs']['version']

    cwl['inputs']['bedfile']['type'] = 'File'

    cwl['inputs']['b']['type'] = ['null', 'File']
    cwl['inputs']['b'].insert(3, 'secondaryFiles', ['.bai'])

    cwl['inputs']['b2']['type'] = ['null', 'File']
    cwl['inputs']['b2'].insert(3, 'secondaryFiles', ['.bai'])

    cwl['inputs']['C']['default'] = True

    cwl['inputs']['c'].insert(1, 'default', '1')

    cwl['inputs']['E'].insert(1, 'default', '3')

    cwl['inputs']['f'].insert(2, 'default', '0.01')

    cwl['inputs']['N2'].insert(1, 'default', 'GRCh37')

    cwl['inputs']['Q'].insert(2, 'default', '20')

    cwl['inputs']['q'].insert(2, 'default', '20')

    cwl['inputs']['S'].insert(1, 'default', '2')

    cwl['inputs']['X'].insert(1, 'default', '5')

    cwl['inputs']['x'].insert(1, 'default', '2000')

    cwl['inputs']['z'].insert(1, 'default', '1')

    cwl['inputs']['G']['type'] = ['null', 'string']

    cwl['inputs']['vcf']['type'] = ['null', 'string']

    #-->
    # fixme: until we can auto generate cwl for VarDict
    # set outputs using outputs.yaml
    import os
    cwl['outputs'] = ruamel.yaml.load(
        read(os.path.dirname(params.filename_cwl) + "/outputs.yaml"),
        ruamel.yaml.RoundTripLoader)['outputs']
    #<--

    # numeric parameter must be wrapped with quotes
    cwl_str = ruamel.yaml.dump(cwl, Dumper=ruamel.yaml.RoundTripDumper)
    cwl_str = re.sub(r"prefix: -3$", "prefix: '-3'", cwl_str, flags=re.MULTILINE)

    write(params.filename_cwl, cwl_str)


if __name__ == "__main__":

    main()
