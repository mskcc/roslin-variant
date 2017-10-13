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

    cwl['inputs']['I']['type'] = ['null', 'File']
    cwl['inputs']['CREATE_INDEX']['default'] = True

# we're doing this way to preserve the order
# can't figure out other ways.
    input_sort_order = """
type: ['null', string]
doc: Optional sort order if the OUTPUT file should be sorted differently than the INPUT file. Possible values - {unsorted, queryname, coordinate}
inputBinding:
  prefix: --SO
"""
    cwl['inputs']['SO'] = ruamel.yaml.load(input_sort_order, ruamel.yaml.RoundTripLoader)

    #-->
    # fixme: until we can auto generate cwl for picard
    # set outputs using outputs.yaml
    import os
    cwl['outputs'] = ruamel.yaml.load(
        read(os.path.dirname(params.filename_cwl) + "/outputs.yaml"),
        ruamel.yaml.RoundTripLoader)['outputs']

    # from : [cmo_picard, --cmd FixMateInformation]
    # to   : [cmo_picard, --cmd, FixMateInformation]
    cwl['baseCommand'] = ['cmo_picard', '--cmd', 'FixMateInformation']
    #<--

    write(params.filename_cwl, ruamel.yaml.dump(
        cwl, Dumper=ruamel.yaml.RoundTripDumper))


if __name__ == "__main__":

    main()
