#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ run_ngs-filters.py --generate_cwl_tool
# Help: $ run_ngs --help_arg2cwl

cwlVersion: "v1.0"

class: CommandLineTool
baseCommand: ['run_ngs-filters.py']

doc: |
   This tool helps to tag hotspot events

inputs:
  
  verbose:
    type: ["null", boolean]
    default: False
    doc: make lots of noise
    inputBinding:
      prefix: --verbose 

  inputMaf:
    type: string
  
    doc: Input maf file which needs to be tagged
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

  NormalPanelMaf:
    type: ["null", string]
    doc: Path to fillout maf file of panel of standard normals
    inputBinding:
      prefix: --normal-panel-maf 

  FFPEPoolMaf:
    type: ["null", string]
    doc: Path to fillout maf file for FFPE artifacts
    inputBinding:
      prefix: --ffpe_pool_maf 

  NormalCohortMaf:
    type: ["null", string]
    doc: Path to fillout maf file of cohort normals
    inputBinding:
      prefix: --normal-cohort-maf 

  NormalCohortSamples:
    type: ["null", string]
    doc: File with list of normal samples
    inputBinding:
      prefix: --normalSamplesFile 

  inputHSP:
    type: ["null", string]
    doc: Input txt file which has hotspots
    inputBinding:
      prefix: --input-hotspot 


outputs:
    []
