#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_delly.py -b cmo_delly.py --version default --cmd merge --generate_cwl_tool
# Help: $ cmo_delly.py  --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['cmo_delly.py --version default --cmd merge']

doc: |
  None

inputs:
  
  version:
    type:
    - "null"
    - type: enum
      symbols: ['default', '0.7.7']
    default: default
  
    inputBinding:
      prefix: --version 

  cmd:
    type: str
  
    doc: delly command, use "--cmd help" for a list of delly commands
    inputBinding:
      prefix: --cmd 

  t:
    type: ["null", string]
    default: DEL
    doc: SV type (DEL, DUP, INV, BND, INS)
    inputBinding:
      prefix: --type 

  o:
    type: ["null", string]
    default: sv.bcf
    doc: Merged SV BCF output file
    inputBinding:
      prefix: --outfile 

  m:
    type: ["null", int]
    default: 0
    doc: min. SV size
    inputBinding:
      prefix: --minsize 

  n:
    type: ["null", int]
    default: 1000000
    doc: max. SV size
    inputBinding:
      prefix: --maxsize 

  c:
    type: ["null", boolean]
    default: False
    doc: Filter sites for PRECISE
    inputBinding:
      prefix: --precise 

  p:
    type: ["null", boolean]
    default: False
    doc: Filter sites for PASS 
    inputBinding:
      prefix: --pass 

  b:
    type: ["null", int]
    default: 1000
    doc: max. breakpoint offset
    inputBinding:
      prefix: --bp-offset 

  r:
    type: ["null", float]
    default: 0.800000012
    doc:  min. reciprocal overlap 
    inputBinding:
      prefix: --rec-overlap 

  i:
    type:
      type: array
      items: string
  
    doc: Input files (sorted bams)
    inputBinding:
      prefix: --input 

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
