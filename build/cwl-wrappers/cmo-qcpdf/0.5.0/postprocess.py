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

    # 8th is right after baseCommand
    cwl.insert(8, 'arguments', ruamel.yaml.load("""
- prefix: --globdir
  valueFrom: ${ return runtime.outdir; }
""", ruamel.yaml.RoundTripLoader))

    cwl['inputs'].insert(0, 'md_metrics_files', ruamel.yaml.load("""
type:
  type: array
  items:
    type: array
    items: File
""", ruamel.yaml.RoundTripLoader))

    cwl['inputs'].insert(1, 'trim_metrics_files', ruamel.yaml.load("""
type:
  type: array
  items:
    type: array
    items:
      type: array
      items:
        type: array
        items: File
""", ruamel.yaml.RoundTripLoader))

    cwl['inputs'].insert(2, 'files', ruamel.yaml.load("""
type:
  type: array
  items: File
""", ruamel.yaml.RoundTripLoader))

    cwl['inputs']['mdmetrics_files']['type'] = 'string'

    cwl['inputs']['gcbias_files']['type'] = 'string'
    cwl['inputs']['insertsize_files']['type'] = 'string'
    cwl['inputs']['hsmetrics_files']['type'] = 'string'
    cwl['inputs']['qualmetrics_files']['type'] = 'string'
    cwl['inputs']['fingerprint_files']['type'] = 'string'
    cwl['inputs']['trimgalore_files']['type'] = 'string'

    cwl['inputs']['fp_genotypes']['type'] = 'File'
    cwl['inputs']['pairing_file']['type'] = 'File'
    cwl['inputs']['grouping_file']['type'] = 'File'
    cwl['inputs']['request_file']['type'] = 'File'

    del cwl['inputs']['globdir']

    #-->
    # fixme: until we can auto generate cwl for cmo-qcpdf
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
