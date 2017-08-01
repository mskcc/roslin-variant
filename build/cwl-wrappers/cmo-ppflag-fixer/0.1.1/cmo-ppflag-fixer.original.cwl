#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_ppflag-fixer --generate_cwl_tool
# Help: $ cmo_ppflag --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['cmo_ppflag-fixer']

doc: |
  run ppflag-fixer

inputs:
  
  max_tlen:
    type: ["null", str]
    doc: Sets a maximum bound of LENGTH on all fragments;any greater and they won't be marked as properpair.
    inputBinding:
      prefix: --max-tlen 

  progress:
    type: ["null", boolean]
    default: False
    doc: Keep track of progress through the file. Thisrequires the file to be indexed.
    inputBinding:
      prefix: --progress 

  input_file:
    type: str
  
    doc: vcf file
    inputBinding:
      position: 1

  output_file:
    type: str
  
    doc: output file
    inputBinding:
      position: 2

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
