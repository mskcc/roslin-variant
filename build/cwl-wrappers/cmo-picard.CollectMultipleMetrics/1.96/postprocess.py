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

    cwl['inputs']['I']['type'] = ruamel.yaml.load("""
- File
- type: array
  items: string
""", ruamel.yaml.RoundTripLoader)

    cwl['inputs']['R']['type'] = ruamel.yaml.load("""
- 'null'
- type: enum
  symbols: ['','GRCm38', 'ncbi36', 'mm9', 'GRCh37', 'GRCh38', 'hg18', 'hg19', 'mm10']
""", ruamel.yaml.RoundTripLoader)

    cwl['inputs']['PROGRAM'] = ruamel.yaml.load("""
type:
  - "null"
  - type: array
    items: string
    inputBinding:
      prefix: --PROGRAM
inputBinding:
  prefix: null
doc: List of metrics programs to apply during the pass through the SAM file. Possible
  values - {CollectAlignmentSummaryMetrics, CollectInsertSizeMetrics, QualityScoreDistribution,
  MeanQualityByCycle} This option may be specified 0 or more times. This option
  can be set to 'null' to clear the default list.
""", ruamel.yaml.RoundTripLoader)

    cwl['inputs']['H'] = ruamel.yaml.load("""
type: ["null", string]
inputBinding:
  prefix: --H
""", ruamel.yaml.RoundTripLoader)

    #-->
    # fixme: until we can auto generate cwl for picard
    # set outputs using outputs.yaml
    import os
    cwl['outputs'] = ruamel.yaml.load(
        read(os.path.dirname(params.filename_cwl) + "/outputs.yaml"),
        ruamel.yaml.RoundTripLoader)['outputs']

    # from : [cmo_picard, --cmd CollectMultipleMetrics]
    # to   : [cmo_picard, --cmd, CollectMultipleMetrics]
    cwl['baseCommand'] = ['cmo_picard', '--cmd', 'CollectMultipleMetrics']
    #<--

    write(params.filename_cwl, ruamel.yaml.dump(
        cwl, Dumper=ruamel.yaml.RoundTripDumper))


if __name__ == "__main__":

    main()
