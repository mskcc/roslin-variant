#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_bcftools norm --generate_cwl_tool
# Help: $ cmo_bcftools norm --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['cmo_bcftools', 'norm']

doc: |
  left-align and normalize indels

inputs:
  
  threads:
    type: ["null", str]
    doc: <int> number of extra output compression threads [0]
    inputBinding:
      prefix: --threads 

  check_ref:
    type: ["null", str]
    doc: <e|w|x|s> check REF alleles and exit (e), warn (w), exclude (x), or set (s) bad sites [e]
    inputBinding:
      prefix: --check-ref 

  remove_duplicates:
    type: ["null", boolean]
    default: False
    doc: remove duplicate lines of the same type.
    inputBinding:
      prefix: --remove-duplicates 

  output_type:
    type: ["null", str]
    doc: <type> 'b' compressed BCF; 'u' uncompressed BCF; 'z' compressed VCF; 'v' uncompressed VCF [v]
    inputBinding:
      prefix: --output-type 

  no_version:
    type: ["null", boolean]
    default: False
    doc: do not append version and command line to the header
    inputBinding:
      prefix: --no-version 

  site_win:
    type: ["null", str]
    doc: <int> buffer for sorting lines which changed position during realignment [1000]
    inputBinding:
      prefix: --site-win 

  rm_dup:
    type: ["null", str]
    doc: <type> remove duplicate snps|indels|both|any
    inputBinding:
      prefix: --rm-dup 

  regions:
    type: ["null", str]
    doc: <region> restrict to comma-separated list of regions
    inputBinding:
      prefix: --regions 

  regions_file:
    type: ["null", str]
    doc: <file> restrict to regions listed in a file
    inputBinding:
      prefix: --regions-file 

  multiallelics:
    type: ["null", str]
    doc: <-|+>[type] split multiallelics (-) or join biallelics (+), type - snps|indels|both|any [both]
    inputBinding:
      prefix: --multiallelics 

  targets:
    type: ["null", str]
    doc: <region> similar to -r but streams rather than index-jumps
    inputBinding:
      prefix: --targets 

  targets_file:
    type: ["null", str]
    doc: <file> similar to -R but streams rather than index-jumps
    inputBinding:
      prefix: --targets-file 

  output:
    type: ["null", str]
    doc: <file> write output to a file [standard output]
    inputBinding:
      prefix: --output 

  strict_filter:
    type: ["null", boolean]
    default: False
    doc: when merging (-m+), merged site is PASS only if all sites being merged PASS
    inputBinding:
      prefix: --strict-filter 

  do_not_normalize:
    type: ["null", boolean]
    default: False
    doc: do not normalize indels (with -m or -c s)
    inputBinding:
      prefix: --do-not-normalize 

  fasta_ref:
    type:
    - "null"
    - type: enum
      symbols: [u'GRCm38', u'ncbi36', u'mm9', u'GRCh37', u'GRCh38', u'hg18', u'hg19', u'mm10']
  
    inputBinding:
      prefix: --fasta-ref 

  vcf:
    type: str
  
  
    inputBinding:
      position: 1


outputs:
    []
