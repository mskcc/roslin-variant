#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_facets doFacets --generate_cwl_tool
# Help: $ cmo_facets doFacets --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['cmo_facets', 'doFacets']

doc: |
  None

inputs:
  
  cval:
    type: ["null", str]
    default: 50
    doc: critical value for segmentation
    inputBinding:
      prefix: --cval 

  snp_nbhd:
    type: ["null", str]
    default: 250
    doc: window size
    inputBinding:
      prefix: --snp_nbhd 

  ndepth:
    type: ["null", str]
    default: 35
    doc: threshold for depth in the normal sample
    inputBinding:
      prefix: --ndepth 

  min_nhet:
    type: ["null", str]
    default: 25
    doc: minimum number of heterozygote snps in a segment used for bivariate t-statistic during clustering of segments
    inputBinding:
      prefix: --min_nhet 

  purity_cval:
    type: ["null", str]
    doc: critical value for segmentation
    inputBinding:
      prefix: --purity_cval 

  purity_snp_nbhd:
    type: ["null", str]
    default: 250
    doc: window size
    inputBinding:
      prefix: --purity_snp_nbhd 

  purity_ndepth:
    type: ["null", str]
    default: 35
    doc: threshold for depth in the normal sample
    inputBinding:
      prefix: --purity_ndepth 

  purity_min_nhet:
    type: ["null", str]
    default: 25
    doc: minimum number of heterozygote snps in a segment used for bivariate t-statistic during clustering of segments
    inputBinding:
      prefix: --purity_min_nhet 

  dipLogR:
    type: ["null", str]
    doc: diploid log ratio
    inputBinding:
      prefix: --dipLogR 

  genome:
    type: ["null", str]
    doc: Genome of counts file
    inputBinding:
      prefix: --genome 

  counts_file:
    type: str
  
    doc: paired Counts File
    inputBinding:
      prefix: --counts_file 

  TAG:
    type: str
  
    doc: output prefix
    inputBinding:
      prefix: --TAG 

  directory:
    type: str
  
    doc: output prefix
    inputBinding:
      prefix: --directory 

  R_lib:
    type: ["null", str]
    default: latest
    doc: Which version of FACETs to load into R
    inputBinding:
      prefix: --R_lib 

  single_chrom:
    type: ["null", str]
    default: F
    doc: Perform analysis on single chromosome
    inputBinding:
      prefix: --single_chrom 

  ggplot2:
    type: ["null", str]
    default: T
    doc: Plots using ggplot2
    inputBinding:
      prefix: --ggplot2 

  seed:
    type: ["null", str]
    doc: Set the seed for reproducibility
    inputBinding:
      prefix: --seed 


outputs:
    []
