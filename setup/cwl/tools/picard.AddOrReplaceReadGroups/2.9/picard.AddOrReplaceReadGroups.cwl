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
  doap:name: picard.AddOrReplaceReadGroups
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

cwlVersion: v1.0

class: CommandLineTool
id: picard-AddOrReplaceReadGroups

arguments:
- valueFrom: "--jar AddOrReplaceReadGroups"
  position: 1

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 25000
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
  O:
    type: string
    doc: Output file (BAM or SAM). Required.
    inputBinding:
      prefix: O=
      position: 2
      separate: false

  SO:
    type: ['null', string]
    doc: Optional sort order to output in. If not supplied OUTPUT is in the same order
      as INPUT. Default value - null. Possible values - {unsorted, queryname, coordinate,
      duplicate, unknown}
    inputBinding:
      prefix: SO=
      position: 2
      separate: false

  ID:
    type: ['null', string]
    doc: Read Group ID Default value - 1. This option can be set to 'null' to clear
      the default value.
    inputBinding:
      prefix: ID=
      position: 2
      separate: false

  LB:
    type: string
    doc: Read Group library Required.
    inputBinding:
      prefix: LB=
      position: 2
      separate: false

  PL:
    type: string
    doc: Read Group platform (e.g. illumina, solid) Required.
    inputBinding:
      prefix: PL=
      position: 2
      separate: false

  PU:
    type: string
    doc: Read Group platform unit (eg. run barcode) Required.
    inputBinding:
      prefix: PU=
      position: 2
      separate: false

  SM:
    type: string
    doc: Read Group sample name Required.
    inputBinding:
      prefix: SM=
      position: 2
      separate: false

  CN:
    type: ['null', string]
    doc: Read Group sequencing center name Default value - null.
    inputBinding:
      prefix: CN=
      position: 2
      separate: false

  DS:
    type: ['null', string]
    doc: Read Group description Default value - null.
    inputBinding:
      prefix: DS=
      position: 2
      separate: false

  DT:
    type: ['null', string]
    doc: Read Group run date Default value - null.
    inputBinding:
      prefix: DT=
      position: 2
      separate: false

  KS:
    type: ['null', string]
    doc: Read Group key sequence Default value - null.
    inputBinding:
      prefix: KS=
      position: 2
      separate: false

  FO:
    type: ['null', string]
    doc: Read Group flow order Default value - null.
    inputBinding:
      prefix: FO=
      position: 2
      separate: false

  PI:
    type: ['null', string]
    doc: Read Group predicted insert size Default value - null.
    inputBinding:
      prefix: PI=
      position: 2
      separate: false

  PG:
    type: ['null', string]
    doc: Read Group program group Default value - null.
    inputBinding:
      prefix: PG=
      position: 2
      separate: false

  PM:
    type: ['null', string]
    doc: Read Group platform model Default value - null.
    inputBinding:
      prefix: PM=
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
    default: true
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
