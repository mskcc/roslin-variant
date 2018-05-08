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
  doap:name: cmo-picard.CollectMultipleMetrics
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
# To generate again: $ cmo_picard -b cmo_picard --version 2.13 --java-version jdk1.8.0_25 --cmd CollectMultipleMetrics --generate_cwl_tool
# Help: $ cmo_picard  --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand: [cmo_picard]
label: cmo-picard(CollectMultipleMetrics)

arguments:
- valueFrom: "CollectMultipleMetrics"
  prefix: --cmd
  position: 0
- valueFrom: "2.9"
  prefix: --version
  position: 1

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 16
    coresMin: 1


doc: |
  None

inputs:
  I:
    type:
    - File
    - type: array
      items: string
    inputBinding:
      prefix: --INPUT

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

  O:
    type: string

    doc: Base name of output files. Required.
    inputBinding:
      prefix: --OUTPUT

  EXT:
    type: ['null', string]
    doc: Append the given file extension to all metric file names (ex. OUTPUT.insert_size_metrics.EXT).
      None if null Default value - null.
    inputBinding:
      prefix: --FILE_EXTENSION

  PROGRAM:
    type:
    - 'null'
    - type: array
      items: string
      inputBinding:
        prefix: --PROGRAM
    inputBinding:
      prefix:
    doc: List of metrics programs to apply during the pass through the SAM file. Possible
      values - {CollectAlignmentSummaryMetrics, CollectInsertSizeMetrics, QualityScoreDistribution,
      MeanQualityByCycle} This option may be specified 0 or more times. This option
      can be set to 'null' to clear the default list.
  INTERVALS:
    type: ['null', string]
    doc: An optional list of intervals to restrict analysis to. Only pertains to some
      of the PROGRAMs. Programs whose stand-alone CLP does not have an INTERVALS argument
      will silently ignore this argument. Default value - null.
    inputBinding:
      prefix: --INTERVALS

  DB_SNP:
    type: ['null', string]
    doc: VCF format dbSNP file, used to exclude regions around known polymorphisms
      from analysis by some PROGRAMs; PROGRAMs whose CLP doesn't allow for this argument
      will quietly ignore it. Default value - null.
    inputBinding:
      prefix: --DB_SNP

  UNPAIRED:
    type: ['null', string]
    doc: Include unpaired reads in CollectSequencingArtifactMetrics. If set to true
      then all paired reads will be included as well - MINIMUM_INSERT_SIZE and MAXIMUM_INSERT_SIZE
      will be ignored in CollectSequencingArtifactMetrics. Default value - false.
      This option can be set to 'null' to clear the default value. Possible values
      - {true, false}
    inputBinding:
      prefix: --INCLUDE_UNPAIRED

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
    - 'null'
    - string
  H:
    type: ['null', string]
    inputBinding:
      prefix: --H
outputs:
  qual_file:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.O)
            return inputs.O.concat('.quality_by_cycle_metrics');
          return null;
        }
  qual_hist:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.O)
            return inputs.O.concat('.quality_by_cycle.pdf');
          return null;
        }
  is_file:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.O)
            return inputs.O.concat('.insert_size_metrics');
          return null;
        }
  is_hist:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.O)
            return inputs.O.concat('.insert_size_histogram.pdf');
          return null;
        }
