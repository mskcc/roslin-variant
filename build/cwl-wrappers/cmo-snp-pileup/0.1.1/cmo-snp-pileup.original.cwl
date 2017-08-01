#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_snp-pileup --generate_cwl_tool
# Help: $ cmo_snp --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['cmo_snp-pileup']

doc: |
  run snp-pileup

inputs:
  
  count_orphans:
    type: ["null", boolean]
    default: False
    doc: Do not discard anomalous read pairs.
    inputBinding:
      prefix: --count-orphans 

  max_depth:
    type: ["null", str]
    doc: Sets the maximum depth. Default is 4000.
    inputBinding:
      prefix: --max-depth 

  gzip:
    type: ["null", boolean]
    default: False
    doc: Compresses the output file with BGZF.
    inputBinding:
      prefix: --gzip 

  progress:
    type: ["null", boolean]
    default: False
    doc: Show a progress bar. WARNING - requires additionaltime to calculate number of SNPs, and will takelonger than normal.
    inputBinding:
      prefix: --progress 

  pseudo_snps:
    type: ["null", str]
    doc: Every MULTIPLE positions, if there is no SNP,insert a blank record with the total count at theposition.
    inputBinding:
      prefix: --pseudo-snps 

  min_map_quality:
    type: ["null", str]
    doc: Sets the minimum threshold for mappingquality. Default is 0.
    inputBinding:
      prefix: --min-map-quality 

  min_base_quality:
    type: ["null", str]
    doc: Sets the minimum threshold for base quality.Default is 0.
    inputBinding:
      prefix: --min-base-quality 

  min_read_counts:
    type: ["null", str]
    default: 10,0
    doc: Comma separated list of minimum read counts fora position to be output. Default is 0.
    inputBinding:
      prefix: --min-read-counts 

  verbose:
    type: ["null", boolean]
    default: False
    doc: Show detailed messages.
    inputBinding:
      prefix: --verbose 

  ignore_overlaps:
    type: ["null", boolean]
    default: False
    doc: Disable read-pair overlap detection.
    inputBinding:
      prefix: --ignore-overlaps 

  vcf:
    type: str
  
    doc: vcf file
    inputBinding:
      position: 1

  output_file:
    type: str
  
    doc: output file
    inputBinding:
      position: 2

  normal_bam:
    type: str
  
    doc: normal bam
    inputBinding:
      position: 3

  tumor_bam:
    type: str
  
    doc: tumor bam
    inputBinding:
      position: 4

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
