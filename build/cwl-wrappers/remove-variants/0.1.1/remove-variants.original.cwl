#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ remove_variants.py --generate_cwl_tool
# Help: $ remove_variants.py --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['remove_variants.py']

doc: |
  Remove snps/indels from the output maf where a complex variant is called

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


outputs:
    []
