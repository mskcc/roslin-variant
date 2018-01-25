#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#

doap:release:
- class: doap:Version
  doap:name: cmo-picard.CalculateHsMetrics
  doap:revision: 2.9
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Christopher Harris
    foaf:mbox: mailto:harrisc2@mskcc.org
  - class: foaf:Person
    foaf:name: Ronak H. Shah
    foaf:mbox: mailto:shahr2@mskcc.org
  - class: foaf:Person
    foaf:name: Nikhil Kumar
    foaf:mbox: mailto:kumarn1@mskcc.org
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_picard -b cmo_picard --version 2.13 --java-version jdk1.8.0_25 --cmd CollectHsMetrics --generate_cwl_tool
# Help: $ cmo_picard  --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- cmo_picard
- --cmd
- CollectHsMetrics
- --version
- 2.9

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 21
    coresMin: 1


doc: |
  None

inputs:
  BI:
    type: File
    doc: An interval list file that contains the locations of the baits used. Default
      value - null. This option must be specified at least 1 times.
    inputBinding:
      prefix: --BAIT_INTERVALS

  N:
    type: ['null', string]
    doc: Bait set name. If not provided it is inferred from the filename of the bait
      intervals. Default value - null.
    inputBinding:
      prefix: --BAIT_SET_NAME

  TI:
    type: File
    doc: An interval list file that contains the locations of the targets. Default
      value - null. This option must be specified at least 1 times.
    inputBinding:
      prefix: --TARGET_INTERVALS

  I:
    type:
    - File
    - type: array
      items: string
    inputBinding:
      prefix: --INPUT

  O:
    type: string

    doc: The output file to write the metrics to. Required.
    inputBinding:
      prefix: --OUTPUT

  LEVEL:
    type:
    - 'null'
    - type: array
      items: string
      inputBinding:
        prefix: --LEVEL
  PER_TARGET_COVERAGE:
    type: ['null', string]
    doc: An optional file to output per target coverage information to. Default value
      - null.
    inputBinding:
      prefix: --PER_TARGET_COVERAGE

  PER_BASE_COVERAGE:
    type: ['null', string]
    doc: An optional file to output per base coverage information to. The per-base
      file contains one line per target base and can grow very large. It is not recommended
      for use with large target sets. Default value - null.
    inputBinding:
      prefix: --PER_BASE_COVERAGE

  NEAR_DISTANCE:
    type: ['null', string]
    doc: The maximum distance between a read and the nearest probe/bait/amplicon for
      the read to be considered 'near probe' and included in percent selected. Default
      value - 250. This option can be set to 'null' to clear the default value.
    inputBinding:
      prefix: --NEAR_DISTANCE

  MQ:
    type: ['null', string]
    doc: Minimum mapping quality for a read to contribute coverage. Default value
      - 20. This option can be set to 'null' to clear the default value.
    inputBinding:
      prefix: --MINIMUM_MAPPING_QUALITY

  Q:
    type: ['null', string]
    doc: Minimum base quality for a base to contribute coverage. Default value - 20.
      This option can be set to 'null' to clear the default value.
    inputBinding:
      prefix: --MINIMUM_BASE_QUALITY

  CLIP_OVERLAPPING_READS:
    type: ['null', string]
    doc: if we are to clip overlapping reads, false otherwise. Default value - true.
      This option can be set to 'null' to clear the default value. Possible values
      - {true, false}
    inputBinding:
      prefix: --CLIP_OVERLAPPING_READS

  COVMAX:
    type: ['null', string]
    doc: Parameter to set a max coverage limit for Theoretical Sensitivity calculations.
      Default is 200. Default value - 200. This option can be set to 'null' to clear
      the default value.
    inputBinding:
      prefix: --COVERAGE_CAP

  SAMPLE_SIZE:
    type: ['null', string]
    doc: Sample Size used for Theoretical Het Sensitivity sampling. Default is 10000.
      Default value - 10000. This option can be set to 'null' to clear the default
      value.
    inputBinding:
      prefix: --SAMPLE_SIZE

  QUIET:
    type: ['null', boolean]
    default: false

    inputBinding:
      prefix: --QUIET

  CREATE_MD5_FILE:
    type: ['null', boolean]
    default: false

    inputBinding:
      prefix: --CREATE_MD5_FILE

  CREATE_INDEX:
    type: ['null', boolean]
    default: false

    inputBinding:
      prefix: --CREATE_INDEX

  TMP_DIR:
    type: ['null', string]
    inputBinding:
      prefix: --TMP_DIR

  VERBOSITY:
    type: ['null', string]
    inputBinding:
      prefix: --VERBOSITY

  VALIDATION_STRINGENCY:
    type: ['null', string]
    inputBinding:
      prefix: --VALIDATION_STRINGENCY

    default: SILENT
  COMPRESSION_LEVEL:
    type: ['null', string]
    inputBinding:
      prefix: --COMPRESSION_LEVEL

  MAX_RECORDS_IN_RAM:
    type: ['null', string]
    inputBinding:
      prefix: --MAX_RECORDS_IN_RAM

  stderr:
    type: ['null', string]
    doc: log stderr to file
    inputBinding:
      prefix: --stderr

  stdout:
    type: ['null', string]
    doc: log stdout to file
    inputBinding:
      prefix: --stdout


  R:
    type:
      type: enum
      symbols: [GRCm38, ncbi36, mm9, GRCh37, GRCh38, hg18, hg19, mm10]
    inputBinding:
      prefix: --R
outputs:
  out_file:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.O)
            return inputs.O;
          return null;
        }
  per_target_out:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.PER_TARGET_COVERAGE)
            return inputs.PER_TARGET_COVERAGE;
          return null;
        }
