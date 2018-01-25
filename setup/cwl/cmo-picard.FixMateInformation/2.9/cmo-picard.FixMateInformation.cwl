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
  doap:name: cmo-picard.FixMateInformation
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
# To generate again: $ cmo_picard -b cmo_picard --version 2.13 --java-version jdk1.8.0_25 --cmd FixMateInformation --generate_cwl_tool
# Help: $ cmo_picard  --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- cmo_picard
- --cmd
- FixMateInformation
- --version
- 2.9

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 30
    coresMin: 4


doc: |
  None

inputs:
  version:
    type:
    - 'null'
    - type: enum
      symbols: [default, '1.124', '1.129', '1.96', '2.13']
    default: default

    inputBinding:
      prefix: --version

  java_version:
    type:
    - 'null'
    - type: enum
      symbols: [default, jdk1.8.0_25, jdk1.7.0_75, jdk1.8.0_31, jre1.7.0_75]
    default: default

    inputBinding:
      prefix: --java-version

  cmd:
    type: string


    inputBinding:
      prefix: --cmd

  I:
    type:
    - 'null'
    - File
    inputBinding:
      prefix: --INPUT

  O:
    type: ['null', string]
    doc: The output file to write to. If no output file is supplied, the input file
      is overwritten. Default value - null.
    inputBinding:
      prefix: --OUTPUT

  SO:
    type: ['null', string]
    doc: Optional sort order if the OUTPUT file should be sorted differently than
      the INPUT file. Possible values - {unsorted, queryname, coordinate}
    inputBinding:
      prefix: --SO
  AS:
    type: ['null', string]
    doc: If true, assume that the input file is queryname sorted, even if the header
      says otherwise. Default value - false. This option can be set to 'null' to clear
      the default value. Possible values - {true, false}
    inputBinding:
      prefix: --ASSUME_SORTED

  MC:
    type: ['null', string]
    doc: Adds the mate CIGAR tag (MC) if true, does not if false. Default value -
      true. This option can be set to 'null' to clear the default value. Possible
      values - {true, false}
    inputBinding:
      prefix: --ADD_MATE_CIGAR

  IGNORE_MISSING_MATES:
    type: ['null', string]
    doc: If true, ignore missing mates, otherwise will throw an exception when missing
      mates are found. Default value - true. This option can be set to 'null' to clear
      the default value. Possible values - {true, false}
    inputBinding:
      prefix: --IGNORE_MISSING_MATES

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
  out_bam:
    type: File
    secondaryFiles: [^.bai]
    outputBinding:
      glob: |
        ${
          if (inputs.O)
            return inputs.O;
          return null;
        }
