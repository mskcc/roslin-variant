#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_picard --generate_cwl_tool
# Help: $ cmo_picard --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['cmo_picard','--cmd','CollectMultipleMetrics','--version','1.96']

doc: |
  None

inputs:
  
  version:
    type:
    - "null"
    - type: enum
      symbols: [u'default', u'1.124', u'1.129', u'1.96']
    default: default
  
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

  cmd:
    type: ["null", str]
  
    inputBinding:
      prefix: --cmd 

  I:
    type:
    - "null"
    - type: array
      items: string
  
  
    inputBinding:
      prefix: --I 

  O:
    type: str
  
    doc: Base name of output files. Required. 
    inputBinding:
      prefix: --O 

  AS:
    type: ["null", str]
    doc: If true (default), then the sort order in the header file will be ignored. Default value - true. This option can be set to 'null' to clear the default value. Possible values - {true, false} 
    inputBinding:
      prefix: --AS 

  R:
    type:
      type: enum
      symbols: [u'GRCm38', u'ncbi36', u'mm9', u'GRCh37', u'GRCh38', u'hg18', u'hg19', u'mm10']
  
    inputBinding:
      prefix: --genome 

  PROGRAM:
    type: ["null", str]
    doc: List of metrics programs to apply during the pass through the SAM file. Possible values - {CollectAlignmentSummaryMetrics, CollectInsertSizeMetrics, QualityScoreDistribution, MeanQualityByCycle} This option may be specified 0 or more times. This option can be set to 'null' to clear the default list. 
    inputBinding:
      prefix: --PROGRAM 

  STOP_AFTER:
    type: ["null", str]
    doc: Stop after processing N reads, mainly for debugging. Default value - 0. This option can be set to 'null' to clear the default value. OUTPUT=String
    inputBinding:
      prefix: --STOP_AFTER 

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
