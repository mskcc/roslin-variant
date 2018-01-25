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
  doap:name: cmo-picard.CollectInsertSizeMetrics
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
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_picard -b cmo_picard --version 2.13 --java-version jdk1.8.0_25 --cmd CollectInsertSizeMetrics --generate_cwl_tool
# Help: $ cmo_picard  --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- cmo_picard
- --cmd
- CollectInsertSizeMetrics
- --version
- 2.9
requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 10
    coresMin: 1


doc: |
  None

inputs:
  H:
    type: string

    doc: File to write insert size Histogram chart to. Required.
    inputBinding:
      prefix: --HISTOGRAM_FILE

  DEVIATIONS:
    type: ['null', string]
    doc: Generate mean, sd and plots by trimming the data down to MEDIAN + DEVIATIONS*MEDIAN_ABSOLUTE_DEVIATION.
      This is done because insert size data typically includes enough anomalous values
      from chimeras and other artifacts to make the mean and sd grossly misleading
      regarding the real distribution. Default value - 10.0. This option can be set
      to 'null' to clear the default value.
    inputBinding:
      prefix: --DEVIATIONS

  W:
    type: ['null', string]
    doc: Explicitly sets the Histogram width, overriding automatic truncation of Histogram
      tail. Also, when calculating mean and standard deviation, only bins <= Histogram_WIDTH
      will be included. Default value - null.
    inputBinding:
      prefix: --HISTOGRAM_WIDTH

  M:
    type: ['null', string]
    doc: When generating the Histogram, discard any data categories (out of FR, TANDEM,
      RF) that have fewer than this percentage of overall reads. (Range - 0 to 1).
      Default value - 0.05. This option can be set to 'null' to clear the default
      value.
    inputBinding:
      prefix: --MINIMUM_PCT

  LEVEL:
    type:
    - 'null'
    - type: array
      items: string
      inputBinding:
        prefix: --LEVEL
  INCLUDE_DUPLICATES:
    type: ['null', string]
    doc: If true, also include reads marked as duplicates in the insert size histogram.
      Default value - false. This option can be set to 'null' to clear the default
      value. Possible values - {true, false}
    inputBinding:
      prefix: --INCLUDE_DUPLICATES

  I:
    type:
    - 'null'
    - File
    inputBinding:
      prefix: --INPUT

  O:
    type: string

    doc: File to write the output to. Required.
    inputBinding:
      prefix: --OUTPUT

  AS:
    type: ['null', string]
    doc: If true (default), then the sort order in the header file will be ignored.
      Default value - true. This option can be set to 'null' to clear the default
      value. Possible values - {true, false}
    inputBinding:
      prefix: --ASSUME_SORTED

  STOP_AFTER:
    type: ['null', string]
    doc: Stop after processing N reads, mainly for debugging. Default value - 0. This
      option can be set to 'null' to clear the default value.
    inputBinding:
      prefix: --STOP_AFTER

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


outputs:
  is_file:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.O)
            return inputs.O;
          return null;
        }
  is_hist:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.H)
            return inputs.H;
          return null;
        }
