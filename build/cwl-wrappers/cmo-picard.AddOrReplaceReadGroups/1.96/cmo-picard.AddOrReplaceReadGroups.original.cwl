#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_picard --generate_cwl_tool
# Help: $ cmo_picard --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['cmo_picard', '--cmd AddOrReplaceReadGroups']

doc: |
  None

inputs:
  
  version:
    type:
    - "null"
    - type: enum
      symbols: [u'default', u'1.124', u'1.129', u'1.96']
    default: 1.96
  
    inputBinding:
      prefix: --version 

  java_version:
    type:
    - "null"
    - type: enum
      symbols: [u'default', u'jdk1.8.0_25', u'jdk1.7.0_75', u'jdk1.8.0_31', u'jre1.7.0_75']
    default: default
  
    inputBinding:
      prefix: --java-version 

  LB:
    type: string
  
    doc: Read Group Library Required. 
    inputBinding:
      prefix: --LB 

  CN:
    type: ["null", str]
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
    - "null"
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
    type: ["null", str]
    doc: Read Group description Default value - null. 
    inputBinding:
      prefix: --DS 

  SO:
    type: ["null", str]
    doc: Optional sort order to output in. If not supplied OUTPUT is in the same order as INPUT. Default value - null. Possible values - {unsorted, queryname, coordinate} 
    inputBinding:
      prefix: --SO 

  SM:
    type: string
  
    doc: Read Group sample name Required. 
    inputBinding:
      prefix: --SM 

  ID:
    type: ["null", str]
    doc: Read Group ID Default value - 1. This option can be set to 'null' to clear the default value. 
    inputBinding:
      prefix: --ID 

  PL:
    type: string
  
    doc: Read Group platform (e.g. illumina, solid) Required. 
    inputBinding:
      prefix: --PL 

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
    type: ["null", str]
  
    inputBinding:
      prefix: --TMP_DIR 

  VERBOSITY:
    type: ["null", str]
  
    inputBinding:
      prefix: --VERBOSITY 

  VALIDATION_STRINGENCY:
    type: ["null", str]
  
    inputBinding:
      prefix: --VALIDATION_STRINGENCY 

  COMPRESSION_LEVEL:
    type: ["null", str]
  
    inputBinding:
      prefix: --COMPRESSION_LEVEL 

  MAX_RECORDS_IN_RAM:
    type: ["null", str]
  
    inputBinding:
      prefix: --MAX_RECORDS_IN_RAM 

  REFERENCE_SEQUENCE:
    type: ["null", str]
  
    inputBinding:
      prefix: --REFERENCE_SEQUENCE 

  stderr:
    type: ["null", str]
    doc: log stderr to file
    inputBinding:
      prefix: --stderr 

  stdout:
    type: ["null", str]
    doc: log stdout to file
    inputBinding:
      prefix: --stdout 


outputs:
    []
