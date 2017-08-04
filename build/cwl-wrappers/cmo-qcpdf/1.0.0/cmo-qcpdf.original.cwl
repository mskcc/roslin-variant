#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_qcpdf --generate_cwl_tool
# Help: $ cmo_qcpdf --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['cmo_qcpdf']

doc: |
  None

inputs:
  
  gcbias_files:
    type:
      type: array
      items: string
  
  
    inputBinding:
      prefix: --gcbias-files 

  mdmetrics_files:
    type:
      type: array
      items: string
  
  
    inputBinding:
      prefix: --mdmetrics-files 

  insertsize_files:
    type:
      type: array
      items: string
  
  
    inputBinding:
      prefix: --insertsize-files 

  hsmetrics_files:
    type:
      type: array
      items: string
  
  
    inputBinding:
      prefix: --hsmetrics-files 

  qualmetrics_files:
    type:
      type: array
      items: string
  
  
    inputBinding:
      prefix: --qualmetrics-files 

  fingerprint_files:
    type:
      type: array
      items: string
  
  
    inputBinding:
      prefix: --fingerprint-files 

  trimgalore_files:
    type:
      type: array
      items: string
  
  
    inputBinding:
      prefix: --trimgalore-files 

  file_prefix:
    type: str
  
  
    inputBinding:
      prefix: --file-prefix 

  fp_genotypes:
    type: str
  
  
    inputBinding:
      prefix: --fp-genotypes 

  pairing_file:
    type: str
  
  
    inputBinding:
      prefix: --pairing-file 

  grouping_file:
    type: str
  
  
    inputBinding:
      prefix: --grouping-file 

  request_file:
    type: str
  
  
    inputBinding:
      prefix: --request-file 


outputs:
    []
