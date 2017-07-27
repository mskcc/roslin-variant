#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_picard --generate_cwl_tool
# Help: $ cmo_picard --help_arg2cwl

cwlVersion: "cwl:v1.0"
requirements:
  InlineJavascriptRequirement: {}

class: CommandLineTool
baseCommand: ['cmo_picard','--cmd','CalculateHsMetrics']

doc: |
  None

inputs:
  
  version:
    type:
    - "null"
    - type: enum
      symbols: ['default', '1.124', '1.129', '1.96']
  
    inputBinding:
      prefix: --version 

  java_version:
    type:
    - "null"
    - type: enum
      symbols: ['default', 'jdk1.8.0_25', 'jdk1.7.0_75', 'jdk1.8.0_31', 'jre1.7.0_75']
  
    inputBinding:
      prefix: --java-version 

  cmd:
    type: ["null", string]
  
    inputBinding:
      prefix: --cmd 

  LEVEL:
    type:
    - "null"
    - type: array
      items: string
  
  
    inputBinding:
      prefix: --LEVEL

  R:
    type:
      - "null"
      - type: enum
        symbols: ['GRCm38', 'ncbi36', 'mm9', 'GRCh37', 'GRCh38', 'hg18', 'hg19', 'mm10']
  
    inputBinding:
      prefix: --R  
  
  I:
    type:
    - File
    - type: array
      items: string
  
  
    inputBinding:
      prefix: --I 

  PER_TARGET_COVERAGE:
    type: ["null", string]
    doc: An optional file to output per target coverage information to. Default value - null. 
    inputBinding:
      prefix: --PER_TARGET_COVERAGE 

  BI:
    type: File
  
    doc: An interval list file that contains the locations of the baits used. Required. BAIT_SET_NAME=String
    inputBinding:
      prefix: --BI 

  O:
    type: string
  
    doc: The output file to write the metrics to. Required. METRIC_ACCUMULATION_LEVEL=MetricAccumulationLevel
    inputBinding:
      prefix: --O 

  N:
    type: ["null", string]
    doc: Bait set name. If not provided it is inferred from the filename of the bait intervals. Default value - null. TARGET_INTERVALS=File
    inputBinding:
      prefix: --N 

  TI:
    type: File
  
    doc: An interval list file that contains the locations of the targets. Required. INPUT=File
    inputBinding:
      prefix: --TI 

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
  out_file:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.O)
            return inputs.O;
          return null;
        }
  per_target_out:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.PER_TARGET_COVERAGE)
            return inputs.PER_TARGET_COVERAGE;
          return null;
        }


