#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_picard --generate_cwl_tool
# Help: $ cmo_picard --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['cmo_picard']

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

  cmd:
    type: ["null", str]
    default: CollectAlignmentSummaryMetrics
  
    inputBinding:
      prefix: --cmd 

  LEVEL:
    type:
    - "null"
    - type: array
      items: string
  
  
    inputBinding:
      prefix: --LEVEL 

  I:
    type:
    - "null"
    - type: array
      items: string
  
  
    inputBinding:
      prefix: --I 

  ADAPTER_SEQUENCE:
    type: ["null", str]
    doc: List of adapter sequences to use when processing the alignment metrics This option may be specified 0 or more times. This option can be set to 'null' to clear the default list. METRIC_ACCUMULATION_LEVEL=MetricAccumulationLevel
    inputBinding:
      prefix: --ADAPTER_SEQUENCE 

  O:
    type: str
  
    doc: File to write the output to. Required. REFERENCE_SEQUENCE=File
    inputBinding:
      prefix: --O 

  AS:
    type: ["null", str]
    doc: If true (default), then the sort order in the header file will be ignored. Default value - true. This option can be set to 'null' to clear the default value. Possible values - {true, false} 
    inputBinding:
      prefix: --AS 

  R:
    type:
    - "null"
    - type: enum
      symbols: [u'GRCm38', u'ncbi36', u'mm9', u'GRCh37', u'GRCh38', u'hg18', u'hg19', u'mm10']
  
    inputBinding:
      prefix: --genome 

  REFERENCE_SEQUENCE:
    type: ["null", str]
  
    inputBinding:
      prefix: --REFERENCE_SEQUENCE 

  MAX_INSERT_SIZE:
    type: ["null", str]
    doc: Paired end reads above this insert size will be considered chimeric along with inter-chromosomal pairs. Default value - 100000. This option can be set to 'null' to clear the default value. 
    inputBinding:
      prefix: --MAX_INSERT_SIZE 

  BS:
    type: ["null", str]
    doc: Whether the SAM or BAM file consists of bisulfite sequenced reads. Default value - false. This option can be set to 'null' to clear the default value. Possible values - {true, false} INPUT=File
    inputBinding:
      prefix: --BS 

  STOP_AFTER:
    type: ["null", str]
    doc: Stop after processing N reads, mainly for debugging. Default value - 0. This option can be set to 'null' to clear the default value. 
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

  CHART:
    type: ["null", str]
  
    inputBinding:
      prefix: --CHART 

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
