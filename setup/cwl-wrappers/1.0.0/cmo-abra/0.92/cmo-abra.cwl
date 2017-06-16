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
  doap:name: cmo-abra
  doap:revision: 0.92
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
# To generate again: $ cmo_abra -o FILENAME --generate_cwl_tool
# Help: $ cmo_abra  --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand: [cmo_abra]

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 30
    coresMin: 5

doc: |
  None

inputs:
  lr:
    type: ['null', boolean]
    default: false
    doc: Search for potential larger local repeats and output to specified file (only
      for multiple samples)
    inputBinding:
      prefix: --lr

  rna_out:
    type: ['null', string]
    doc: Output RNA sam or bam file (required if RNA input file specified)
    inputBinding:
      prefix: --rna-out

  bwa_ref:
    type: ['null', string]
    doc: BWA index prefix. Use this only if the bwa index prefix does not match the
      ref option.
    inputBinding:
      prefix: --bwa-ref

  kmer:
    type: ['null', string]
    doc: Optional assembly kmer size(delimit with commas if multiple sizes specified)
    inputBinding:
      prefix: --kmer

  aur:
    type: ['null', string]
    doc: Assemble unaligned reads (currently disabled).
    inputBinding:
      prefix: --aur

  mur:
    type: ['null', string]
    doc: Maximum number of unaligned reads to assemble (default - 50000000)
    inputBinding:
      prefix: --mur

  mc_mapq:
    type: ['null', string]
    doc: Minimum contig mapping quality (default - 25)
    inputBinding:
      prefix: --mc-mapq

  mapq:
    type: ['null', string]
    doc: Minimum mapping quality for a read to be used in assembly and be eligible
      for realignment (default - 20)
    inputBinding:
      prefix: --mapq

  ref:
    type:
      type: enum
      symbols: [GRCm38, hg19, ncbi36, mm9, GRCh37, mm10, hg18, GRCh38]
    inputBinding:
      prefix: --reference_sequence

  ib:
    type: ['null', boolean]
    default: false
    doc: If specified, write intermediate data to BAM file using the intel deflator
      when available. Use this to speed up processing.
    inputBinding:
      prefix: --ib

  mbq:
    type: ['null', string]
    doc: Minimum base quality for inclusion in assembly. This value is compared against
      the sum of base qualities per kmer position (default - 60)
    inputBinding:
      prefix: --mbq

  mnf:
    type: ['null', string]
    doc: Assembly minimum node frequency (default - 2)
    inputBinding:
      prefix: --mnf

  in:
    type: 

      type: array
      items: File
    doc: Required list of input sam or bam file (s) separated by comma
    inputBinding:
      itemSeparator: ','
      prefix: --in

    secondaryFiles:
    - ^.bai
  rcf:
    type: ['null', string]
    doc: Minimum read candidate fraction for triggering assembly (default - 0.01)
    inputBinding:
      prefix: --rcf

  working:
    type: string

    doc: Working directory for intermediate output. Must not already exist
    inputBinding:
      prefix: --working

  threads:
    type: ['null', string]
    doc: Number of threads (default - 4)
    inputBinding:
      prefix: --threads

  adc:
    type: ['null', string]
    doc: Skip regions with average depth greater than this value (default - 100000)
    inputBinding:
      prefix: --adc

  out:
    type: 

      type: array
      items: string
    doc: Required list of output sam or bam file (s) separated by comma
    inputBinding:
      itemSeparator: ','
      prefix: --out

  sv:
    type: ['null', string]
    doc: Enable Structural Variation searching (experimental, only supported for paired
      end)
    inputBinding:
      prefix: --sv

  mer:
    type: ['null', string]
    doc: Min edge pruning ratio. Default value is appropriate for relatively sensitive
      somatic cases. May be increased for improved speed in germline only cases. (default
      - 0.02)
    inputBinding:
      prefix: --mer

  mcl:
    type: ['null', string]
    doc: Assembly minimum contig length (default - -1)
    inputBinding:
      prefix: --mcl

  mad:
    type: ['null', string]
    doc: Regions with average depth exceeding this value will be downsampled (default
      - 250)
    inputBinding:
      prefix: --mad

  single:
    type: ['null', string]
    doc: Input is single end
    inputBinding:
      prefix: --single

  target_kmers:
    type: ['null', string]
    doc: BED-like file containing target regions with per region kmer sizes in 4th
      column
    inputBinding:
      prefix: --target-kmers

  targets:
    type: ['null', File, string]
    doc: BED file containing target regions
    inputBinding:
      prefix: --targets

  rna:
    type: ['null', string]
    doc: Input RNA sam or bam file (currently disabled)
    inputBinding:
      prefix: --rna

  mpc:
    type: ['null', string]
    doc: Maximum number of potential contigs for a region (default - 5000)
    inputBinding:
      prefix: --mpc

  umnf:
    type: ['null', string]
    doc: Assembly minimum unaligned node frequency (default - 2)
    inputBinding:
      prefix: --umnf


outputs:
  outbams:
    type: File[]
    outputBinding:
      glob: '*.abra.bam'
