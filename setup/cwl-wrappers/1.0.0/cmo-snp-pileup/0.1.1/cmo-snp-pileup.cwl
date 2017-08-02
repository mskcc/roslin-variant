#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#

doap:release:
- class: doap:Version
  doap:name: cmo-snp-pileup
  doap:revision: 0.1.1
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_snp-pileup --generate_cwl_tool
# Help: $ cmo_snp --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- sing.sh
- htstools
- 0.1.1
- snp-pileup

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 5
    coresMin: 1

doc: |
  run snp-pileup

inputs:
  count_orphans:
    type: ['null', boolean]
    default: false
    doc: Do not discard anomalous read pairs.
    inputBinding:
      prefix: --count-orphans

  max_depth:
    type: ['null', string]
    doc: Sets the maximum depth. Default is 4000.
    inputBinding:
      prefix: --max-depth

  gzip:
    type: ['null', boolean]
    default: false
    doc: Compresses the output file with BGZF.
    inputBinding:
      prefix: --gzip

  progress:
    type: ['null', boolean]
    default: false
    doc: Show a progress bar. WARNING - requires additionaltime to calculate number
      of SNPs, and will takelonger than normal.
    inputBinding:
      prefix: --progress

  pseudo_snps:
    type: ['null', string]
    doc: Every MULTIPLE positions, if there is no SNP,insert a blank record with the
      total count at theposition.
    inputBinding:
      prefix: --pseudo-snps

  min_map_quality:
    type: ['null', string]
    doc: Sets the minimum threshold for mappingquality. Default is 0.
    inputBinding:
      prefix: --min-map-quality

  min_base_quality:
    type: ['null', string]
    doc: Sets the minimum threshold for base quality.Default is 0.
    inputBinding:
      prefix: --min-base-quality

  min_read_counts:
    type: ['null', string]
    default: 10,0
    doc: Comma separated list of minimum read counts fora position to be output. Default
      is 0.
    inputBinding:
      prefix: --min-read-counts

  verbose:
    type: ['null', boolean]
    default: false
    doc: Show detailed messages.
    inputBinding:
      prefix: --verbose

  ignore_overlaps:
    type: ['null', boolean]
    default: false
    doc: Disable read-pair overlap detection.
    inputBinding:
      prefix: --ignore-overlaps

  vcf:
    type: string

    doc: vcf file
    inputBinding:
      position: 1

  output_file:
    type: string

    doc: output file
    inputBinding:
      position: 2

  normal_bam:
    type: string

    doc: normal bam
    inputBinding:
      position: 3

  tumor_bam:
    type: string

    doc: tumor bam
    inputBinding:
      position: 4

  stderr:
    type: ['null', string]
    doc: log stderr to file
    inputBinding:
      prefix: --stderr

  stdout:
    type: ['null', string]
    doc: log stdout to file
    inputBinding:
      prefix: --stdout


outputs: []
