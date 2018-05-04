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
  doap:name: cmo-picard.CollectGcBiasMetrics
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
# To generate again: $ cmo_picard -b cmo_picard --version 2.13 --java-version jdk1.8.0_25 --cmd CollectGcBiasMetrics --generate_cwl_tool
# Help: $ cmo_picard  --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- cmo_picard
- --cmd
- CollectGcBiasMetrics
- --version
- "2.9"

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 16
    coresMin: 1


doc: |
  None

inputs:
  CHART:
    type: string

    doc: The PDF file to render the chart to. Required.
    inputBinding:
      prefix: --CHART_OUTPUT

  S:
    type: string

    doc: The text file to write summary metrics to. Required.
    inputBinding:
      prefix: --SUMMARY_OUTPUT

  R:
    type:
    - 'null'
    - string
    inputBinding:
       prefix: --genome

  WINDOW_SIZE:
    type: ['null', string]
    doc: The size of the scanning windows on the reference genome that are used to
      bin reads. Default value - 100. This option can be set to 'null' to clear the
      default value.
    inputBinding:
      prefix: --SCAN_WINDOW_SIZE

  MGF:
    type: ['null', string]
    doc: For summary metrics, exclude GC windows that include less than this fraction
      of the genome. Default value - 1.0E-5. This option can be set to 'null' to clear
      the default value.
    inputBinding:
      prefix: --MINIMUM_GENOME_FRACTION

  BS:
    type: ['null', string]
    doc: Whether the SAM or BAM file consists of bisulfite sequenced reads. Default
      value - false. This option can be set to 'null' to clear the default value.
      Possible values - {true, false}
    inputBinding:
      prefix: --IS_BISULFITE_SEQUENCED

  ALSO_IGNORE_DUPLICATES:
    type: ['null', string]
    doc: to get additional results without duplicates. This option allows to gain
      two plots per level at the same time - one is the usual one and the other excludes
      duplicates. Default value - false. This option can be set to 'null' to clear
      the default value. Possible values - {true, false}
    inputBinding:
      prefix: --ALSO_IGNORE_DUPLICATES

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
  pdf:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.CHART)
            return inputs.CHART;
          return null;
        }
  out_file:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.O)
            return inputs.O;
          return null;
        }
  summary:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.S)
            return inputs.S;
          return null;
        }
