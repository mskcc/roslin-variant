#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ replace_allele_counts.py --generate_cwl_tool
# Help: $ replace_allele_counts.py --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['replace_allele_counts.py']

doc: |
  This tool helps to replace the allele counts from the caller with the allele counts of GetBaseCountMultiSample

inputs:
  
  verbose:
    type: ["null", boolean]
    default: False
    doc: make lots of noise
    inputBinding:
      prefix: --verbose 

  inputMaf:
    type: string
  
    doc: Input maf file which needs to be fixed
    inputBinding:
      prefix: --input-maf 

  fillout:
    type: string
  
    doc: Input fillout file created by GetBaseCountMultiSample using the input maf
    inputBinding:
      prefix: --fillout 

  outputMaf:
    type: string
  
    doc: Output maf file name
    inputBinding:
      prefix: --output-maf 

  outdir:
    type: ["null", string]
    doc: Full Path to the output dir.
    inputBinding:
      prefix: --outDir 

  num_threads:
    type: ["null", int]
    default: 5
    doc: number of threads to use to do merge (default 5)
    inputBinding:
      prefix: --num-threads 


outputs:
    []
