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

    # fixme: call sing.sh directly until cmo_list2bed is released
    # cwl['baseCommand'] = 'cmo_list2bed'
    cwl['baseCommand'] = ['sing.sh', 'list2bed', '1.0.0']

# we're doing this way to preserve the order
# can't figure out other ways.
    input_file_type = """
- string
- File
- type: array
  items: string
"""
    cwl['inputs']['input_file']['type'] = ruamel.yaml.load(input_file_type, ruamel.yaml.RoundTripLoader)

    write(params.filename_cwl, ruamel.yaml.dump(
        cwl, Dumper=ruamel.yaml.RoundTripDumper))


if __name__ == "__main__":

    main()
