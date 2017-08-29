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
  doap:revision: 1.96
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
# To generate again: $ cmo_picard --generate_cwl_tool
# Help: $ cmo_picard --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- cmo_picard
- --version
- "1.129"
- --cmd
- CollectGcBiasMetrics

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 10
    coresMin: 1


doc: |
  None

inputs:
  cmd:
    type: ['null', string]
    default: CollectGcBiasMetrics

    inputBinding:
      prefix: --cmd

  AS:
    type: ['null', string]
    doc: If true, assume that the input file is coordinate sorted, even if the header
      says otherwise. Default value - false. This option can be set to 'null' to clear
      the default value. Possible values - {true, false} IS_BISULFITE_SEQUENCED=Boolean
    inputBinding:
      prefix: --AS

  WINDOW_SIZE:
    type: ['null', string]
    doc: The size of windows on the genome that are used to bin reads. Default value
      - 100. This option can be set to 'null' to clear the default value.
    inputBinding:
      prefix: --WINDOW_SIZE

  I:
    type:
    - 'null'
    - File
    inputBinding:
      prefix: --I

  CHART:
    type: string

    doc: The PDF file to render the chart to. Required. SUMMARY_OUTPUT=File
    inputBinding:
      prefix: --CHART

  O:
    type: string

    doc: The text file to write the metrics table to. Required. CHART_OUTPUT=File
    inputBinding:
      prefix: --O

  S:
    type: ['null', string]
    doc: The text file to write summary metrics to. Default value - null.
    inputBinding:
      prefix: --S

  R:
    type:
    - 'null'
    - type: enum
      symbols: [GRCm38, ncbi36, mm9, GRCh37, GRCh38, hg18, hg19, mm10]
    inputBinding:
      prefix: --genome

  REFERENCE_SEQUENCE:
    type: ['null', string]
    inputBinding:
      prefix: --REFERENCE_SEQUENCE

  MINIMUM_GENOME_FRACTION:
    type: ['null', string]
    doc: summary metrics, exclude GC windows that include less than this fraction
      of the genome. Default value - 1.0E-5. This option can be set to 'null' to clear
      the default value. ASSUME_SORTED=Boolean
    inputBinding:
      prefix: --MINIMUM_GENOME_FRACTION

  BS:
    type: ['null', string]
    doc: Whether the SAM or BAM file consists of bisulfite sequenced reads. Default
      value - false. This option can be set to 'null' to clear the default value.
      Possible values - {true, false}
    inputBinding:
      prefix: --BS

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
