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
    default: CollectGcBiasMetrics
  
    inputBinding:
      prefix: --cmd 

  AS:
    type: ["null", str]
    doc: If true, assume that the input file is coordinate sorted, even if the header says otherwise. Default value - false. This option can be set to 'null' to clear the default value. Possible values - {true, false} IS_BISULFITE_SEQUENCED=Boolean
    inputBinding:
      prefix: --AS 

  WINDOW_SIZE:
    type: ["null", str]
    doc: The size of windows on the genome that are used to bin reads. Default value - 100. This option can be set to 'null' to clear the default value. 
    inputBinding:
      prefix: --WINDOW_SIZE 

  I:
    type:
    - "null"
    - type: array
      items: string
  
  
    inputBinding:
      prefix: --I 

  CHART:
    type: str
  
    doc: The PDF file to render the chart to. Required. SUMMARY_OUTPUT=File
    inputBinding:
      prefix: --CHART 

  O:
    type: str
  
    doc: The text file to write the metrics table to. Required. CHART_OUTPUT=File
    inputBinding:
      prefix: --O 

  S:
    type: ["null", str]
    doc: The text file to write summary metrics to. Default value - null. 
    inputBinding:
      prefix: --S 

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

  MINIMUM_GENOME_FRACTION:
    type: ["null", str]
    doc: summary metrics, exclude GC windows that include less than this fraction of the genome. Default value - 1.0E-5. This option can be set to 'null' to clear the default value. ASSUME_SORTED=Boolean
    inputBinding:
      prefix: --MINIMUM_GENOME_FRACTION 

  BS:
    type: ["null", str]
    doc: Whether the SAM or BAM file consists of bisulfite sequenced reads. Default value - false. This option can be set to 'null' to clear the default value. Possible values - {true, false} 
    inputBinding:
      prefix: --BS 

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
