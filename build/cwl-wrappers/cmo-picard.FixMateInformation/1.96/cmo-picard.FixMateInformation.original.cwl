#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_picard --generate_cwl_tool
# Help: $ cmo_picard --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['cmo_picard', '--version 1.96', '--cmd FixMateInformation']

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
    type: ["null", str]
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
