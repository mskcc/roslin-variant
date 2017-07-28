#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_picard --generate_cwl_tool
# Help: $ cmo_picard --help_arg2cwl

cwlVersion: "cwl:v1.0"
requirements:
  InlineJavascriptRequirement: {}

class: CommandLineTool
baseCommand: ['cmo_picard','--cmd','CollectMultipleMetrics']

doc: |
  None

inputs:
  
  version:
    type:
    - "null"
    - type: enum
      symbols: ['default', '1.124', '1.129', '1.96']
    default: default
  
    inputBinding:
      prefix: --version 

  java_version:
    type:
    - "null"
    - type: enum
      symbols: ['default', 'jdk1.8.0_25', 'jdk1.7.0_75', 'jdk1.8.0_31', 'jre1.7.0_75']
    default: default
  
    inputBinding:
      prefix: --java-version 

  cmd:
    type: ["null", string]
  
    inputBinding:
      prefix: --cmd 
  H:
    type: ["null", string]
    inputBinding:
      prefix: --H

  I:
    type:
    - File
    - type: array
      items: string
  
  
    inputBinding:
      prefix: --I 

  O:
    type: string
  
    doc: Base name of output files. Required. 
    inputBinding:
      prefix: --O 

  AS:
    type: ["null", string]
    doc: If true (default), then the sort order in the header file will be ignored. Default value - true. This option can be set to 'null' to clear the default value. Possible values - {true, false} 
    inputBinding:
      prefix: --AS 

  R:
    type:
      - "null"
      - type: enum
        symbols: ['','GRCm38', 'ncbi36', 'mm9', 'GRCh37', 'GRCh38', 'hg18', 'hg19', 'mm10']
  
    inputBinding:
      prefix: --genome 

  PROGRAM:
    type:
      - "null"
      - type: array
        items: string
        inputBinding:
          prefix: --PROGRAM
    inputBinding:
      prefix: null
    
  STOP_AFTER:
    type: ["null", string]
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
  qual_file:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.O)
            return inputs.O.concat('.quality_by_cycle_metrics');
          return null;
        }
  qual_hist:
    type: File?
    outputBinding:
      glob: |
        ${ if (inputs.O)
             return inputs.O.concat('.quality_by_cycle.pdf');
           return null;
        }
  is_file:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.O)
            return inputs.O.concat('.insert_size_metrics');
          return null;
        }
  is_hist:
    type: File?
    outputBinding:
      glob: |
        ${ if (inputs.O)
             return inputs.O.concat('.insert_size_histogram.pdf');
           return null;
        }
