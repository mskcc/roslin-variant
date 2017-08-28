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
  doap:revision: 2.07
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Nikhil Kumar
    foaf:mbox: mailto:kumarn1@mskcc.org

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
baseCommand:
- cmo_abra
- --version
- '2.07'

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 30
    coresMin: 15


doc: |
  None

inputs:
  threads:
    type: ['null', string]
    doc: Number of threads (default - 4)
    inputBinding:
      prefix: --threads

    default: '15'
  bwa_ref:
    type: ['null', string]
    doc: bwa ref
    inputBinding:
      prefix: --bwa-ref

  mmr:
    type: ['null', string]
    doc: Max allowed mismatch rate when mapping reads back to contigs (default - 0.05)
    inputBinding:
      prefix: --mmr

  kmer:
    type: ['null', string]
    doc: Optional assembly kmer size(delimit with commas if multiple sizes specified)
    inputBinding:
      prefix: --kmer

  contigs:
    type: ['null', string]
    doc: Optional file to which assembled contigs are written
    inputBinding:
      prefix: --contigs

  ssc:
    type: ['null', string]
    doc: Skip usage of soft clipped sequences as putative contigs
    inputBinding:
      prefix: --ssc

  keep_tmp:
    type: ['null', string]
    doc: Do not delete the temporary directory
    inputBinding:
      prefix: --keep-tmp

  gtf:
    type: ['null', string]
    doc: GTF file defining exons and transcripts
    inputBinding:
      prefix: --gtf

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

  out:
    type: 

      type: array
      items: string
    doc: Required list of output sam or bam file (s) separated by comma
    inputBinding:
      itemSeparator: ','
      prefix: --out

  sga:
    type: ['null', string]
    doc: Scoring used for contig alignments (match, mismatch_penalty, gap_open_penalty,
      gap_extend_penalty) (default - 8,32,48,1)
    inputBinding:
      prefix: --sga

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

  cons:
    type: ['null', string]
    doc: Use positional consensus sequence when aligning high quality soft clipping
    inputBinding:
      prefix: --cons

  nosort:
    type: ['null', string]
    doc: Do not attempt to sort final output
    inputBinding:
      prefix: --nosort

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
  ca:
    type: ['null', string]
    doc: Contig anchor [M_bases_at_contig_edge, max_mismatches_at_edge (default -
      10,2)
    inputBinding:
      prefix: --ca

  rcf:
    type: ['null', string]
    doc: Minimum read candidate fraction for triggering assembly (default - 0.01)
    inputBinding:
      prefix: --rcf

  maxn:
    type: ['null', string]
    doc: Maximum pre-pruned nodes in regional assembly (default - 9000)
    inputBinding:
      prefix: --maxn

  working:
    doc: Working directory for intermediate output. Must not already exist
    inputBinding:
      prefix: --working
    type: string
  cl:
    type: ['null', string]
    doc: Compression level of output bam file (s) (default - 5)
    inputBinding:
      prefix: --cl

  sc:
    type: ['null', string]
    doc: Soft clip contig args [max_contigs, min_base_qual,frac_high_qual_bases, min_soft_clip_len]
      (default - 32,13,80,8)
    inputBinding:
      prefix: --sc

  sa:
    type: ['null', string]
    doc: Skip assembly
    inputBinding:
      prefix: --sa

  junctions:
    type: ['null', string]
    doc: Splice junctions definition file
    inputBinding:
      prefix: --junctions

  mrr:
    type: ['null', string]
    doc: Regions containing more reads than this value are not processed. Use -1 to
      disable. (default - 10000)
    inputBinding:
      prefix: --mrr

  sobs:
    type: ['null', string]
    doc: Do not use observed indels in original alignments to generate contigs
    inputBinding:
      prefix: --sobs

  dist:
    type: ['null', string]
    doc: Max read move distance (default - 500000)
    inputBinding:
      prefix: --dist

  mer:
    type: ['null', string]
    doc: Min edge pruning ratio. Default value is appropriate for relatively sensitive
      somatic cases. May be increased for improved speed in germline only cases. (default
      - 0.02)
    inputBinding:
      prefix: --mer

  tmpdir:
    type: ['null', string]
    doc: Set the temp directory (overrides java. io.tmpdir)
    inputBinding:
      prefix: --tmpdir

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

  ws:
    type: ['null', string]
    doc: Processing window size and overlap (size,overlap) (default - 400,200)
    inputBinding:
      prefix: --ws

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

  log:
    type: ['null', string]
    doc: Logging level (trace,debug,info,warn, error) (default - info)
    inputBinding:
      prefix: --log

  mcr:
    type: ['null', string]
    doc: Max number of cached reads per sample per thread (default - 500000)
    inputBinding:
      prefix: --mcr


outputs:
  outbams:
    type: File[]
    outputBinding:
      glob: '*.abra.bam'
