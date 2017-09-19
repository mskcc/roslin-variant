#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ filter_vardict.py --generate_cwl_tool
# Help: $ filter_vardict.py --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['filter_vardict.py']

doc: |
  Filter snps/indels from the output of vardict v1.4.6

inputs:
  
  verbose:
    type: ["null", boolean]
    default: False
    doc: make lots of noise
    inputBinding:
      prefix: --verbose 

  inputVcf:
    type: string
  
    doc: Input vcf vardict file which needs to be filtered
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

  hotspotVcf:
    type: ["null", string]
    doc: Input bgzip / tabix indexed hotspot vcf file to used for filtering
    inputBinding:
      prefix: --hotspotVcf 

  outdir:
    type: ["null", string]
    doc: Full Path to the output dir.
    inputBinding:
      prefix: --outDir 


outputs:
    []
