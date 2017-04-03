#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
  - http://dublincore.org/2012/06/14/dcterms.rdf
  - http://xmlns.com/foaf/spec/20140114.rdf
  - http://usefulinc.com/ns/doap#

doap:name: cmo-picard.FixMateInformation.cwl
doap:release:
  - class: doap:Version
    doap:revision: '1.96'

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

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['cmo_picard', '--version 1.96', '--cmd FixMateInformation']

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 30
    coresMin: 5


doc: |
  None

inputs:

  I:
    type:
    - "null"
    - type: array
      items: string
  
  
    inputBinding:
      prefix: --I 

  O:
    type: ["null", string]
    doc: The output file to write to. If no output file is supplied, the input file is overwritten. Default value - null. 
    inputBinding:
      prefix: --O 

  QUIET:
    type: ["null", boolean]
    default: False
  
    inputBinding:
      prefix: --QUIET 

  CREATE_MD5_FILE:
    type: ["null", boolean]
    default: False
  
    inputBinding:
      prefix: --CREATE_MD5_FILE 

  CREATE_INDEX:
    type: ["null", boolean]
    default: False
  
    inputBinding:
      prefix: --CREATE_INDEX 

  TMP_DIR:
    type: ["null", string]
  
    inputBinding:
      prefix: --TMP_DIR 

  VERBOSITY:
    type: ["null", string]
  
    inputBinding:
      prefix: --VERBOSITY 

  VALIDATION_STRINGENCY:
    type: ["null", string]
  
    inputBinding:
      prefix: --VALIDATION_STRINGENCY 

  COMPRESSION_LEVEL:
    type: ["null", string]
  
    inputBinding:
      prefix: --COMPRESSION_LEVEL 

  MAX_RECORDS_IN_RAM:
    type: ["null", string]
  
    inputBinding:
      prefix: --MAX_RECORDS_IN_RAM 

  REFERENCE_SEQUENCE:
    type: ["null", string]
  
    inputBinding:
      prefix: --REFERENCE_SEQUENCE 

  stderr:
    type: ["null", string]
    doc: log stderr to file
    inputBinding:
      prefix: --stderr 

  stdout:
    type: ["null", string]
    doc: log stdout to file
    inputBinding:
      prefix: --stdout 


outputs:
    []
