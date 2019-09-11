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
  doap:name: abra
  doap:revision: 2.17
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

cwlVersion: v1.0

class: CommandLineTool
id: abra

arguments:
- valueFrom: "-jar"
  position: 1

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: $(inputs.abra_ram_min)
    coresMin: 16
  DockerRequirement:
    dockerPull: mskcc/roslin-variant-abra:2.17


doc: |
  None

inputs:

  java_args:
    type: string
    default: "-Xmx36g"
    inputBinding:
      position: 0

  abra_ram_min:
    type: int

  threads:
    type: ['null', string]
    doc: Number of threads (default - 16)
    inputBinding:
      prefix: --threads
      position: 2
    default: '16'

  bwa_ref:
    type: ['null', string]
    doc: bwa ref
    inputBinding:
      prefix: --bwa-ref
      position: 2

  mmr:
    type: ['null', string]
    doc: Max allowed mismatch rate when mapping reads back to contigs (default - 0.05)
    inputBinding:
      prefix: --mmr
      position: 2

  kmer:
    type: ['null', string]
    doc: Optional assembly kmer size(delimit with commas if multiple sizes specified)
    inputBinding:
      prefix: --kmer
      position: 2

  skip:
    type: ['null', string]
    doc: If no target specified, skip realignment of chromosomes matching specified
      regex. Skipped reads are output without modification. Specify none to disable.
      (default - GL.*|hs37d5|chr.*random|chrUn. *|chrEBV|CMV|HBV|HCV.*|HIV. *|KSHV|HTLV.*|MCV|SV40|HPV.*)
    inputBinding:
      prefix: --skip
      position: 2

  sua:
    type: ['null', string]
    doc: Do not use unmapped reads anchored by mate to trigger assembly. These reads
      are still eligible to contribute to assembly
    inputBinding:
      prefix: --sua
      position: 2

  contigs:
    type: ['null', string]
    doc: Optional file to which assembled contigs are written
    inputBinding:
      prefix: --contigs
      position: 2

  ssc:
    type: ['null', string]
    doc: Skip usage of soft clipped sequences as putative contigs
    inputBinding:
      prefix: --ssc
      position: 2

  keep_tmp:
    type: ['null', string]
    doc: Do not delete the temporary directory
    inputBinding:
      prefix: --keep-tmp
      position: 2

  gtf:
    type: ['null', string]
    doc: GTF file defining exons and transcripts
    inputBinding:
      prefix: --gtf
      position: 2

  mapq:
    type: ['null', string]
    doc: Minimum mapping quality for a read to be used in assembly and be eligible
      for realignment (default - 20)
    inputBinding:
      prefix: --mapq
      position: 2

  ref:
    type: File
    inputBinding:
      prefix: --ref
      position: 2

  index:
    type: ['null', string]
    doc: Enable BAM index generation when outputting sorted alignments (may require
      additonal memory)
    inputBinding:
      prefix: --index
      position: 2

  out:
    type:
      type: array
      items: string
    doc: Required list of output sam or bam file (s) separated by comma
    inputBinding:
      itemSeparator: ','
      prefix: --out
      position: 2

  sga:
    type: ['null', string]
    doc: Scoring used for contig alignments (match, mismatch_penalty, gap_open_penalty,
      gap_extend_penalty) (default - 8,32,48,1)
    inputBinding:
      prefix: --sga
      position: 2

  mbq:
    type: ['null', string]
    doc: Minimum base quality for inclusion in assembly. This value is compared against
      the sum of base qualities per kmer position (default - 20)
    inputBinding:
      prefix: --mbq
      position: 2

  mnf:
    type: ['null', string]
    doc: Assembly minimum node frequency (default - 1)
    inputBinding:
      prefix: --mnf
      position: 2

  cons:
    type: ['null', string]
    doc: Use positional consensus sequence when aligning high quality soft clipping
    inputBinding:
      prefix: --cons
      position: 2

  msr:
    type: ['null', string]
    doc: Max reads to keep in memory per sample during the sort phase. When this value
      is exceeded, sort spills to disk (default - 1000000)
    inputBinding:
      prefix: --msr
      position: 2

  nosort:
    type: ['null', string]
    doc: Do not attempt to sort final output
    inputBinding:
      prefix: --nosort
      position: 2

  in:
    type:

      type: array
      items: File
    doc: Required list of input sam or bam file (s) separated by comma
    inputBinding:
      itemSeparator: ','
      prefix: --in
      position: 2

    secondaryFiles:
    - ^.bai
  ca:
    type: ['null', string]
    doc: Contig anchor [M_bases_at_contig_edge, max_mismatches_near_edge] (default
      - 10,2)
    inputBinding:
      prefix: --ca
      position: 2

  rcf:
    type: ['null', string]
    doc: Minimum read candidate fraction for triggering assembly (default - 0.01)
    inputBinding:
      prefix: --rcf
      position: 2

  gkl:
    type: ['null', string]
    doc: If specified, use GKL Intel Deflater (experimental)
    inputBinding:
      prefix: --gkl
      position: 2

  maxn:
    type: ['null', string]
    doc: Maximum pre-pruned nodes in regional assembly (default - 150000)
    inputBinding:
      prefix: --maxn
      position: 2

  undup:
    type: ['null', string]
    doc: Unset duplicate flag
    inputBinding:
      prefix: --undup
      position: 2

  working:
    doc: Working directory for intermediate output. Must not already exist
    inputBinding:
      prefix: --working
      position: 2
    type: string

  cl:
    type: ['null', string]
    doc: Compression level of output bam file (s) (default - 5)
    inputBinding:
      prefix: --cl
      position: 2

  sc:
    type: ['null', string]
    doc: Soft clip contig args [max_contigs, min_base_qual,frac_high_qual_bases, min_soft_clip_len]
      (default - 16,13,80,15)
    inputBinding:
      prefix: --sc
      position: 2

  sa:
    type: ['null', string]
    doc: Skip assembly
    inputBinding:
      prefix: --sa
      position: 2

  mrn:
    type: ['null', string]
    doc: Reads with noise score exceeding this value are not remapped. numMismatches+(numIndels*2)
      < readLength*mnr (default - 0.1)
    inputBinding:
      prefix: --mrn
      position: 2

  junctions:
    type: ['null', string]
    doc: Splice junctions definition file
    inputBinding:
      prefix: --junctions
      position: 2

  mrr:
    type: ['null', string]
    doc: Regions containing more reads than this value are not processed. Use -1 to
      disable. (default - 1000000)
    inputBinding:
      prefix: --mrr
      position: 2

  sobs:
    type: ['null', string]
    doc: Do not use observed indels in original alignments to generate contigs
    inputBinding:
      prefix: --sobs
      position: 2

  dist:
    type: ['null', string]
    doc: Max read move distance (default - 1000)
    inputBinding:
      prefix: --dist
      position: 2

  mer:
    type: ['null', string]
    doc: Min edge pruning ratio. Default value is appropriate for relatively sensitive
      somatic cases. May be increased for improved speed in germline only cases. (default
      - 0.01)
    inputBinding:
      prefix: --mer
      position: 2

  amq:
    type: ['null', string]
    doc: Set mapq for alignments that map equally well to reference and an ABRA generated
      contig. default of -1 disables (default - -1)
    inputBinding:
      prefix: --amq
      position: 2

  tmpdir:
    type: ['null', string]
    doc: Set the temp directory (overrides java. io.tmpdir)
    inputBinding:
      prefix: --tmpdir
      position: 2

  mcl:
    type: ['null', string]
    doc: Assembly minimum contig length (default - -1)
    inputBinding:
      prefix: --mcl
      position: 2

  mad:
    type: ['null', string]
    doc: Regions with average depth exceeding this value will be downsampled (default
      - 1000)
    inputBinding:
      prefix: --mad
      position: 2

  single:
    type: ['null', string]
    doc: Input is single end
    inputBinding:
      prefix: --single
      position: 2

  ws:
    type: ['null', string]
    doc: Processing window size and overlap (size,overlap) (default - 400,200)
    inputBinding:
      prefix: --ws
      position: 2

  mac:
    type: ['null', string]
    doc: Max assembled contigs (default - 64)
    inputBinding:
      prefix: --mac
      position: 2

  in_vcf:
    type: ['null', string]
    doc: VCF containing known (or suspected) variant sites. Very large files should
      be avoided.
    inputBinding:
      prefix: --in-vcf
      position: 2

  target_kmers:
    type: ['null', string]
    doc: BED-like file containing target regions with per region kmer sizes in 4th
      column
    inputBinding:
      prefix: --target-kmers
      position: 2

  targets:
    type: ['null', File, string]
    doc: BED file containing target regions
    inputBinding:
      prefix: --targets
      position: 2

  log:
    type: ['null', string]
    doc: Logging level (trace,debug,info,warn, error) (default - info)
    inputBinding:
      prefix: --log
      position: 2

  mcr:
    type: ['null', string]
    doc: Max number of cached reads per sample per thread (default - 1000000)
    inputBinding:
      prefix: --mcr
      position: 2


outputs:
  outbams:
    type: File[]
    outputBinding:
      glob: |
        ${
          return inputs.out;
        }
