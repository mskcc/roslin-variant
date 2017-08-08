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
    default: CollectInsertSizeMetrics
  
    inputBinding:
      prefix: --cmd 

  DEVIATIONS:
    type: ["null", str]
    doc: Generate mean, sd and plots by trimming the data down to MEDIAN + DEVIATIONS*MEDIAN_ABSOLUTE_DEVIATION. This is done because insert size data typically includes enough anomalous values from chimeras and other artifacts to make the mean and sd grossly misleading regarding the real distribution. Default value - 10.0. This option can be set to 'null' to clear the default value. HISTOGRAM_WIDTH=Integer
    inputBinding:
      prefix: --DEVIATIONS 

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

  H:
    type: str
  
    doc: File to write insert size histogram chart to. Required. 
    inputBinding:
      prefix: --H 

  M:
    type: ["null", str]
    doc: When generating the histogram, discard any data categories (out of FR, TANDEM, RF) that have fewer than this percentage of overall reads. (Range - 0 to 1). Default value - 0.05. This option can be set to 'null' to clear the default value. METRIC_ACCUMULATION_LEVEL=MetricAccumulationLevel
    inputBinding:
      prefix: --M 

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

  W:
    type: ["null", str]
    doc: Explicitly sets the histogram width, overriding automatic truncation of histogram tail. Also, when calculating mean and standard deviation, only bins <= HISTOGRAM_WIDTH will be included. Default value - null. MINIMUM_PCT=Float
    inputBinding:
      prefix: --W 

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
