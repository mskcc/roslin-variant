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
  doap:name: picard.CollectGcBiasMetrics
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

cwlVersion: v1.0

class: CommandLineTool
id: picard-CollectGcBiasMetrics

arguments:
- valueFrom: "-jar CollectGcBiasMetrics"
  position: 1

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 16000
    coresMin: 1
  DockerRequirement:
    dockerPull: mskcc/roslin-variant-picard:2.9


doc: |
  None

inputs:

  java_args:
    type: string
    default: "-Xms256m -Xmx30g -XX:-UseGCOverheadLimit"
    inputBinding:
      position: 0

  java_temp:
    type: string
    inputBinding:
      prefix: -Djava.io.tmpdir=
      position: 0
      separate: false

  TMP_DIR:
    type: string
    inputBinding:
      prefix: TMP_DIR=
      position: 2
      separate: false

  I:
    type: File
    inputBinding:
      prefix: I=
      position: 2
      separate: false

  CHART:
    type: string
    doc: The PDF file to render the chart to. Required.
    inputBinding:
      prefix: CHART_OUTPUT=
      position: 2
      separate: false

  S:
    type: string
    doc: The text file to write summary metrics to. Required.
    inputBinding:
      prefix: SUMMARY_OUTPUT=
      position: 2
      separate: false

  WINDOW_SIZE:
    type: ['null', string]
    doc: The size of the scanning windows on the reference genome that are used to
      bin reads. Default value - 100. This option can be set to 'null' to clear the
      default value.
    inputBinding:
      prefix: SCAN_WINDOW_SIZE=
      position: 2
      separate: false

  MGF:
    type: ['null', string]
    doc: For summary metrics, exclude GC windows that include less than this fraction
      of the genome. Default value - 1.0E-5. This option can be set to 'null' to clear
      the default value.
    inputBinding:
      prefix: MINIMUM_GENOME_FRACTION=
      position: 2
      separate: false

  BS:
    type: ['null', boolean]
    doc: Whether the SAM or BAM file consists of bisulfite sequenced reads. Default
      value - false. This option can be set to 'null' to clear the default value.
      Possible values - {true, false}
    inputBinding:
      prefix: IS_BISULFITE_SEQUENCED=True
      position: 2

  ALSO_IGNORE_DUPLICATES:
    type: ['null', boolean]
    doc: to get additional results without duplicates. This option allows to gain
      two plots per level at the same time - one is the usual one and the other excludes
      duplicates. Default value - false. This option can be set to 'null' to clear
      the default value. Possible values - {true, false}
    inputBinding:
      prefix: ALSO_IGNORE_DUPLICATES=True
      position: 2

  O:
    type: string
    doc: File to write the output to. Required.
    inputBinding:
      prefix: O=
      position: 2
      separate: false

  AS:
    type: ['null', boolean]
    doc: If true (default), then the sort order in the header file will be ignored.
      Default value - true. This option can be set to 'null' to clear the default
      value. Possible values - {true, false}
    inputBinding:
      prefix: ASSUME_SORTED=True
      position: 2

  STOP_AFTER:
    type: ['null', string]
    doc: Stop after processing N reads, mainly for debugging. Default value - 0. This
      option can be set to 'null' to clear the default value.
    inputBinding:
      prefix: STOP_AFTER=
      position: 2
      separate: false

  QUIET:
    type: ['null', boolean]
    default: false
    inputBinding:
      prefix: QUIET=True
      position: 2

  CREATE_MD5_FILE:
    type: ['null', boolean]
    default: false
    inputBinding:
      prefix: CREATE_MD5_FILE=True
      position: 2

  CREATE_INDEX:
    type: ['null', boolean]
    default: false
    inputBinding:
      prefix: CREATE_INDEX=True
      position: 2

  VERBOSITY:
    type: ['null', string]
    inputBinding:
      prefix: VERBOSITY=
      position: 2
      separate: false

  VALIDATION_STRINGENCY:
    type: ['null', string]
    default: SILENT
    inputBinding:
      prefix: VALIDATION_STRINGENCY=
      position: 2
      separate: false

  COMPRESSION_LEVEL:
    type: ['null', string]
    inputBinding:
      prefix: COMPRESSION_LEVEL=
      position: 2
      separate: false

  MAX_RECORDS_IN_RAM:
    type: ['null', string]
    inputBinding:
      prefix: MAX_RECORDS_IN_RAM=
      position: 2
      separate: false

outputs:
  pdf:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.CHART)
            return inputs.CHART;
          return null;
        }
  out_file:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.O)
            return inputs.O;
          return null;
        }
  summary:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.S)
            return inputs.S;
          return null;
        }
