#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_delly.py -b cmo_delly.py --version default --cmd call --generate_cwl_tool
# Help: $ cmo_delly.py  --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['cmo_delly.py --version default --cmd call']

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

  g:
    type:
    - "null"
    - type: enum
      symbols: [u'GRCm38', u'hg19', u'ncbi36', u'mm9', u'GRCh37', u'mm10', u'hg18', u'GRCh38']
    doc: genome fasta file
    inputBinding:
      prefix: --genome 

  x:
    type: ["null", string]
    doc: file with regions to exclude
    inputBinding:
      prefix: --exclude 

  o:
    type: ["null", string]
    default: sv.bcf
    doc: SV BCF output file 
    inputBinding:
      prefix: --outfile 

  q:
    type: ["null", int]
    default: 1
    doc: min. paired-end mapping quality
    inputBinding:
      prefix: --map-qual 

  s:
    type: ["null", int]
    default: 9
    doc: insert size cutoff, median+s*MAD (deletions only)
    inputBinding:
      prefix: --mad-cutoff 

  n:
    type: ["null", boolean]
    default: False
    doc: no small InDel calling 
    inputBinding:
      prefix: --noindels 

  v:
    type: ["null", string]
    doc: input VCF/BCF file for re-genotyping
    inputBinding:
      prefix: --vcffile 

  u:
    type: ["null", int]
    default: 5
    doc: min. mapping quality for genotyping 
    inputBinding:
      prefix: --geno-qual 

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
