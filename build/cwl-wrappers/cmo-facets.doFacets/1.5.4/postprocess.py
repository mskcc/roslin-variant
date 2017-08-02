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

    cwl['baseCommand'] = ['sing.sh', 'facets', '1.5.4', 'doFacets']

    cwl['inputs']['cval']['type'] = ['null', 'int']
    cwl['inputs']['snp_nbhd']['type'] = ['null', 'int']
    cwl['inputs']['ndepth']['type'] = ['null', 'int']
    cwl['inputs']['min_nhet']['type'] = ['null', 'int']
    cwl['inputs']['purity_cval']['type'] = ['null', 'int']
    cwl['inputs']['purity_snp_nbhd']['type'] = ['null', 'int']
    cwl['inputs']['purity_ndepth']['type'] = ['null', 'int']
    cwl['inputs']['purity_min_nhet']['type'] = ['null', 'int']
    cwl['inputs']['counts_file']['type'] = 'File'

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
