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
  doap:name: cmo-picard.AddOrReplaceReadGroups
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
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_picard --generate_cwl_tool
# Help: $ cmo_picard --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand: [cmo_picard]

arguments:
- --cmd
- AddOrReplaceReadGroups

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 8
    coresMin: 1

doc: |
  None

inputs:
  LB:
    type: string

    doc: Read Group Library Required.
    inputBinding:
      prefix: --LB

  CN:
    type: ['null', string]
    doc: Read Group sequencing center name Default value - null.
    inputBinding:
      prefix: --CN

  PU:
    type: string

    doc: Read Group platform unit (eg. run barcode) Required.
    inputBinding:
      prefix: --PU

  I:
    type:
    - 'null'
    - File
    - type: array
      items: string


    inputBinding:
      prefix: --I

  O:
    type: string

    doc: Output file (bam or sam). Required.
    inputBinding:
      prefix: --O

  DS:
    type: ['null', string]
    doc: Read Group description Default value - null.
    inputBinding:
      prefix: --DS

  SO:
    type: ['null', string]
    doc: Optional sort order to output in. If not supplied OUTPUT is in the same order
      as INPUT. Default value - null. Possible values - {unsorted, queryname, coordinate}
    inputBinding:
      prefix: --SO

  SM:
    type: string

    doc: Read Group sample name Required.
    inputBinding:
      prefix: --SM

  ID:
    type: ['null', string]
    doc: Read Group ID Default value - 1. This option can be set to 'null' to clear
      the default value.
    inputBinding:
      prefix: --ID

  PL:
    type: string

    doc: Read Group platform (e.g. illumina, solid) Required.
    inputBinding:
      prefix: --PL

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
    default: true

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
  bam:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.O)
            return inputs.O;
          return null;
        }
  bai:
    type: File?
    outputBinding:
      glob: |-
        ${
          if (inputs.O)
            return inputs.O.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '').replace(/\.bam/,'') + ".bai";
          return null;
        }
