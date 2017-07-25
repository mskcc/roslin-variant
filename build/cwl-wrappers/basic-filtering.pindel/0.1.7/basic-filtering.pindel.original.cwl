#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ filter_pindel.py --generate_cwl_tool
# Help: $ filter_pindel.py --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['filter_pindel.py']

doc: |
  Filter indels from the output of pindel v0.2.5a7

inputs:
  
  verbose:
    type: ["null", boolean]
    default: True
    doc: make lots of noise
    inputBinding:
      prefix: --verbose 

  inputVcf:
    type: string
  
    doc: Input vcf freebayes file which needs to be filtered
    inputBinding:
      prefix: --inputVcf 

  tsampleName:
    type: string
  
    doc: Name of the tumor Sample
    inputBinding:
      prefix: --tsampleName 

  dp:
    type: ["null", int]
    default: 0
    doc: Tumor total depth threshold
    inputBinding:
      prefix: --totaldepth 

  ad:
    type: ["null", int]
    default: 5
    doc: Tumor allele depth threshold
    inputBinding:
      prefix: --alleledepth 

  tnr:
    type: ["null", int]
    default: 5
    doc: Tumor-Normal variant frequency ratio threshold 
    inputBinding:
      prefix: --tnRatio 

  vf:
    type: ["null", float]
    default: 0.01
    doc: Tumor variant frequency threshold 
    inputBinding:
      prefix: --variantfrequency 

  outdir:
    type: ["null", string]
    doc: Full Path to the output dir.
    inputBinding:
      prefix: --outDir 

  min:
    type: ["null", int]
    default: 25
    doc: Minimum length of the indels
    inputBinding:
      prefix: --min_var_len 

  max:
    type: ["null", int]
    default: 2000
    doc: Max length of the indels
    inputBinding:
      prefix: --max_var_len 

  hotspotVcf:
    type: ["null", string]
    doc: Input bgzip / tabix indexed hotspot vcf file to used for filtering
    inputBinding:
      prefix: --hotspotVcf 


outputs:
    []
