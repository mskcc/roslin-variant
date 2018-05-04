
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
  doap:revision: 1.129
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

#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_picard --generate_cwl_tool
# Help: $ cmo_picard --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 16
    coresMin: 1

baseCommand: [cmo_picard]

arguments:
- --version
- "1.129"
- --cmd
- CalculateHsMetrics

doc: |
  None

inputs:
  cmd:
    type: ['null', string]
    inputBinding:
      prefix: --cmd

  LEVEL:
    type:
    - 'null'
    - type: array
      items: string
      inputBinding:
        prefix: --LEVEL
  I:
    type:
    - File
    - type: array
      items: string
    inputBinding:
      prefix: --I

  PER_TARGET_COVERAGE:
    type: ['null', string]
    doc: An optional file to output per target coverage information to. Default value
      - null.
    inputBinding:
      prefix: --PER_TARGET_COVERAGE

  BI:
    type: File

    doc: An interval list file that contains the locations of the baits used. Required.
      BAIT_SET_NAME=String
    inputBinding:
      prefix: --BI

  O:
    type: string

    doc: The output file to write the metrics to. Required. METRIC_ACCUMULATION_LEVEL=MetricAccumulationLevel
    inputBinding:
      prefix: --O

  N:
    type: ['null', string]
    doc: Bait set name. If not provided it is inferred from the filename of the bait
      intervals. Default value - null. TARGET_INTERVALS=File
    inputBinding:
      prefix: --N

#  R:
#    type:
#      type: enum
#      symbols: [GRCm38, ncbi36, mm9, GRCh37, GRCh38, hg18, hg19, mm10]
#    inputBinding:
#      prefix: --R

  TI:
    type: File

    doc: An interval list file that contains the locations of the targets. Required.
      INPUT=File
    inputBinding:
      prefix: --TI

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

  REFERENCE_SEQUENCE:
    type: ['null', string]
    inputBinding:
      prefix: --REFERENCE_SEQUENCE

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
