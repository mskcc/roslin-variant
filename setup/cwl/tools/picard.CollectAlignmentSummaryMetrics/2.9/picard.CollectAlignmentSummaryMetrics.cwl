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
  doap:name: picard.CollectAlignmentSummaryMetrics
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
# To generate again: $ cmo_picard -b cmo_picard --version 2.13 --java-version jdk1.8.0_25 --cmd CollectAlignmentSummaryMetrics --generate_cwl_tool
# Help: $ cmo_picard  --help_arg2cwl

cwlVersion: v1.0

class: CommandLineTool
id: picard-CollectAlignmentSummaryMetrics


arguments:
- valueFrom: "--jar CollectAlignmentSummaryMetrics"
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

  MAX_INSERT_SIZE:
    type: ['null', string]
    doc: Paired-end reads above this insert size will be considered chimeric along
      with inter-chromosomal pairs. Default value - 100000. This option can be set
      to 'null' to clear the default value.
    inputBinding:
      prefix: MAX_INSERT_SIZE=
      position: 2
      separate: false

  EXPECTED_PAIR_ORIENTATIONS:
    type: ['null', string]
    doc: Paired-end reads that do not have this expected orientation will be considered
      chimeric. Default value - [FR]. This option can be set to 'null' to clear the
      default value. Possible values - {FR, RF, TANDEM} This option may be specified
      0 or more times. This option can be set to 'null' to clear the default list.
    inputBinding:
      prefix: EXPECTED_PAIR_ORIENTATIONS=
      position: 2
      separate: false

  ADAPTER_SEQUENCE:
    type: ['null', string]
    doc: List of adapter sequences to use when processing the alignment metrics. Default
      value - [AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT, AGATCGGAAGAGCTCGTATGCCGTCTTCTGCTTG,
      AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT, AGATCGGAAGAGCGGTTCAGCAGGAATGCCGAGACCGATCTCGTATGCCGTCTTCTGCTTG,
      AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT, AGATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNNNATCTCGTATGCCGTCTTCTGCTTG].
      This option can be set to 'null' to clear the default value. This option may
      be specified 0 or more times. This option can be set to 'null' to clear the
      default list.
    inputBinding:
      prefix: ADAPTER_SEQUENCE=
      position: 2
      separate: false

  LEVEL:
    type:
    - 'null'
    - type: array
      items: string
      inputBinding:
        prefix: LEVEL=
        separate: false
        position: 2
  BS:
    type: ['null', string]
    doc: Whether the SAM or BAM file consists of bisulfite sequenced reads. Default
      value - false. This option can be set to 'null' to clear the default value.
      Possible values - {true, false}
    inputBinding:
      prefix: IS_BISULFITE_SEQUENCED=
      separate: false
      position: 2

  O:
    type: string
    doc: File to write the output to. Required.
    inputBinding:
      prefix: O=
      separate: false
      position: 2

  AS:
    type: ['null',boolean]
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
      separate: false
      position: 2

  REFERENCE_SEQUENCE:
    type: File
    inputBinding:
      prefix: REFERENCE_SEQUENCE=
      separate: false
      position: 2

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
      separate: false
      position: 2

  VALIDATION_STRINGENCY:
    type: ['null', string]
    default: SILENT
    inputBinding:
      prefix: VALIDATION_STRINGENCY=
      separate: false
      position: 2

  COMPRESSION_LEVEL:
    type: ['null', string]
    inputBinding:
      prefix: COMPRESSION_LEVEL=
      separate: false
      position: 2

  MAX_RECORDS_IN_RAM:
    type: ['null', string]
    inputBinding:
      prefix: MAX_RECORDS_IN_RAM=
      separate: false
      position: 2

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
