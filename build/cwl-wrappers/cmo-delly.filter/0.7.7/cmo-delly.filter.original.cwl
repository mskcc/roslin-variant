#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_delly.py -b cmo_delly.py --version default --cmd filter --generate_cwl_tool
# Help: $ cmo_delly.py  --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['cmo_delly.py --version default --cmd filter']

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

  f:
    type: ["null", string]
    default: somatic
    doc: Filter mode (somatic, germline)
    inputBinding:
      prefix: --filter 

  o:
    type: ["null", string]
    default: sv.bcf
    doc: Filtered SV BCF output file
    inputBinding:
      prefix: --outfile 

  a:
    type: ["null", float]
    default: 0.200000003
    doc: min. fractional ALT support
    inputBinding:
      prefix: --altaf 

  m:
    type: ["null", int]
    default: 500
    doc: min. SV size
    inputBinding:
      prefix: --minsize 

  n:
    type: ["null", int]
    default: 500000000
    doc: max. SV size
    inputBinding:
      prefix: --maxsize 

  r:
    type: ["null", float]
    default: 0.75
    doc: min. fraction of genotyped samples
    inputBinding:
      prefix: --ratiogeno 

  p:
    type: ["null", boolean]
    default: False
    doc: Filter sites for PASS 
    inputBinding:
      prefix: --pass 

  s:
    type: ["null", string]
    doc: Two-column sample file listing sample name and tumor or control
    inputBinding:
      prefix: --samples 

  v:
    type: ["null", int]
    default: 10
    doc: min. coverage in tumor
    inputBinding:
      prefix: --coverage 

  c:
    type: ["null", int]
    default: 0
    doc:  max. fractional ALT support in control 
    inputBinding:
      prefix: --controlcontamination 

  q:
    type: ["null", int]
    default: 15
    doc: min. median GQ for carriers and non-carriers
    inputBinding:
      prefix: --gq 

  e:
    type: ["null", float]
    default: 0.800000012
    doc: max. read-depth ratio of carrier vs. non-carrier for a deletion
    inputBinding:
      prefix: --rddel 

  u:
    type: ["null", float]
    default: 1.20000005
    doc: min. read-depth ratio of carrier vs. non-carrier for a duplication 
    inputBinding:
      prefix: --rddup 

  i:
    type:
      type: array
      items: string
  
    doc: Input files (sorted bams)
    inputBinding:
      prefix: --input 

  all_regions:
    type: ["null", boolean]
    default: False
    doc: include regions marked in this genome
    inputBinding:
      prefix: --all_regions 

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
