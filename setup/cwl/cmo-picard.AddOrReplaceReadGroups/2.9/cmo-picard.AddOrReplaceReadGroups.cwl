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
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_picard -b cmo_picard --version 2.13 --java-version jdk1.8.0_25 --cmd AddOrReplaceReadGroups --generate_cwl_tool
# Help: $ cmo_picard  --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand: [cmo_picard]
label: cmo-picard(AddOrReplaceReadGroups)

arguments:
- valueFrom: "AddOrReplaceReadGroups"
  prefix: --cmd
  position: 0
- valueFrom: "2.9"
  prefix: --version
  position: 1

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 8
    coresMin: 1

doc: |
  None

inputs:  

  I:
    type:
    - 'null'
    - File
    - type: array
      items: string


    inputBinding:
      prefix: --INPUT

  O:
    type: string

    doc: Output file (BAM or SAM). Required.
    inputBinding:
      prefix: --OUTPUT

  SO:
    type: ['null', string]
    doc: Optional sort order to output in. If not supplied OUTPUT is in the same order
      as INPUT. Default value - null. Possible values - {unsorted, queryname, coordinate,
      duplicate, unknown}
    inputBinding:
      prefix: --SORT_ORDER

  ID:
    type: ['null', string]
    doc: Read Group ID Default value - 1. This option can be set to 'null' to clear
      the default value.
    inputBinding:
      prefix: --RGID

  LB:
    type: string

    doc: Read Group library Required.
    inputBinding:
      prefix: --RGLB

  PL:
    type: string

    doc: Read Group platform (e.g. illumina, solid) Required.
    inputBinding:
      prefix: --RGPL

  PU:
    type: string

    doc: Read Group platform unit (eg. run barcode) Required.
    inputBinding:
      prefix: --RGPU

  SM:
    type: string

    doc: Read Group sample name Required.
    inputBinding:
      prefix: --RGSM

  CN:
    type: ['null', string]
    doc: Read Group sequencing center name Default value - null.
    inputBinding:
      prefix: --RGCN

  DS:
    type: ['null', string]
    doc: Read Group description Default value - null.
    inputBinding:
      prefix: --RGDS

  DT:
    type: ['null', string]
    doc: Read Group run date Default value - null.
    inputBinding:
      prefix: --RGDT

  KS:
    type: ['null', string]
    doc: Read Group key sequence Default value - null.
    inputBinding:
      prefix: --RGKS

  FO:
    type: ['null', string]
    doc: Read Group flow order Default value - null.
    inputBinding:
      prefix: --RGFO

  PI:
    type: ['null', string]
    doc: Read Group predicted insert size Default value - null.
    inputBinding:
      prefix: --RGPI

  PG:
    type: ['null', string]
    doc: Read Group program group Default value - null.
    inputBinding:
      prefix: --RGPG

  PM:
    type: ['null', string]
    doc: Read Group platform model Default value - null.
    inputBinding:
      prefix: --RGPM

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
