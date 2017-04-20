#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#

doap:name: cmo-vardict.cwl
doap:release:
- class: doap:Version
  doap:revision: 1.4.6

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
# To generate again: $ cmo_vardict -o FILENAME --generate_cwl_tool
# Help: $ cmo_vardict  --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- cmo_vardict
- --version
- 1.4.6

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 10
    coresMin: 5

doc: |
  None

inputs:
  bedfile:
    type: File


    inputBinding:
      position: 1

  three:
    type: ['null', boolean]
    default: false
    doc: Indicate to move indels to 3-prime if alternative alignment can be achieved.
    inputBinding:
      prefix: -3

  a:
    type: ['null', string]
    doc: Indicate it's amplicon based calling. Reads don't map to the amplicon will
      be skipped. A read pair is considered belonging the amplicon if the edges are
      less than int bp to the amplicon, and overlap fraction is at least float. Default
      - 10 -0.95
    inputBinding:
      prefix: -a

  B:
    type: ['null', string]
    doc: The minimum # of reads to determine strand bias, default 2
    inputBinding:
      prefix: -B

  b2:
    type: 

      - 'null'
      - File
    doc: Normal bam
    inputBinding:
      prefix: -b2

    secondaryFiles:
    - .bai
  b:
    type:
    - 'null'
    - File
    doc: Tumor bam
    inputBinding:
      prefix: -b

    secondaryFiles:
    - .bai
  C:
    type: ['null', boolean]
    default: true
    doc: Indicate the chromosome names are just numbers, such as 1, 2, not chr1, chr2
    inputBinding:
      prefix: -C

  c:
    type: ['null', string]
    default: '1'
    doc: The column for chromosome
    inputBinding:
      prefix: -c

  D:
    type: ['null', boolean]
    default: false
    doc: Debug mode. Will print some error messages and append full genotype at the
      end.
    inputBinding:
      prefix: -D

  d:
    type: ['null', string]
    doc: The delimiter for split region_info, default to tab "\t"
    inputBinding:
      prefix: -d

  E:
    type: ['null', string]
    default: '3'
    doc: The column for region end, e.g. gene end
    inputBinding:
      prefix: -E

  e:
    type: ['null', string]
    doc: The column for segment ends in the region, e.g. exon ends
    inputBinding:
      prefix: -e

  F:
    type: ['null', string]
    doc: The hexical to filter reads using samtools. Default - 0x500 (filter 2nd alignments
      and duplicates). Use -F 0 to turn it off.
    inputBinding:
      prefix: -F

  f:
    type: ['null', string]
    doc: The threshold for allele frequency, default - 0.05 or 5%%
    default: '0.01'
    inputBinding:
      prefix: -f

  g:
    type: ['null', string]
    doc: The column for gene name, or segment annotation
    inputBinding:
      prefix: -g

  H:
    type: ['null', boolean]
    default: false
    doc: Print this help page
    inputBinding:
      prefix: -H

  hh:
    type: ['null', boolean]
    default: false
    doc: Print a header row decribing columns
    inputBinding:
      prefix: -hh

  I:
    type: ['null', string]
    doc: The indel size. Default - 120bp
    inputBinding:
      prefix: -I

  i:
    type: ['null', boolean]
    default: false
    doc: Output splicing read counts
    inputBinding:
      prefix: -i

  k:
    type: ['null', string]
    doc: Indicate whether to perform local realignment. Default - 1. Set to 0 to disable
      it. For Ion or PacBio, 0 is recommended.
    inputBinding:
      prefix: -k

  M:
    type: ['null', string]
    doc: The minimum matches for a read to be considered. If, after soft-clipping,
      the matched bp is less than INT, then the read is discarded. It's meant for
      PCR based targeted sequencing where there's no insert and the matching is only
      the primers. Default - 0, or no filtering
    inputBinding:
      prefix: -M

  m:
    type: ['null', string]
    doc: If set, reads with mismatches more than INT will be filtered and ignored.
      Gaps are not counted as mismatches. Valid only for bowtie2/TopHat or BWA aln
      followed by sampe. BWA mem is calculated as NM - Indels. Default - 8, or reads
      with more than 8 mismatches will not be used.
    inputBinding:
      prefix: -m

  N2:
    type: string

    default: GRCh37
    doc: Normal Sample Name
    inputBinding:
      prefix: -N2

  N:
    type: ['null', string]
    doc: Tumor Sample Name
    inputBinding:
      prefix: -N

  n:
    type: ['null', string]
    doc: The regular expression to extract sample name from bam filenames. Default
      to - /([^\/\._]+?)_[^\/]*.bam/
    inputBinding:
      prefix: -n

  O:
    type: ['null', string]
    doc: The reads should have at least mean MapQ to be considered a valid variant.
      Default - no filtering
    inputBinding:
      prefix: -O

  o:
    type: ['null', string]
    doc: The Qratio of (good_quality_reads)/(bad_quality_reads+0.5). The quality is
      defined by -q option. Default - 1.5
    inputBinding:
      prefix: -o

  P:
    type: ['null', string]
    doc: The read position filter. If the mean variants position is less that specified,
      it's considered false positive. Default - 5
    inputBinding:
      prefix: -P

  p:
    type: ['null', boolean]
    default: false
    doc: Do pileup regarless the frequency
    inputBinding:
      prefix: -p

  Q:
    type: ['null', string]
    doc: If set, reads with mapping quality less than INT will be filtered and ignored
    default: '20'
    inputBinding:
      prefix: -Q

  q:
    type: ['null', string]
    doc: The phred score for a base to be considered a good call. Default - 25 (for
      Illumina) For PGM, set it to ~15, as PGM tends to under estimate base quality.
    default: '20'
    inputBinding:
      prefix: -q

  R:
    type: ['null', string]
    doc: The region of interest. In the format of chr -start-end. If end is omitted,
      then a single position. No BED is needed.
    inputBinding:
      prefix: -R

  r:
    type: ['null', string]
    doc: The minimum # of variance reads, default 2
    inputBinding:
      prefix: -r

  S:
    type: ['null', string]
    default: '2'
    doc: The column for region start, e.g. gene start
    inputBinding:
      prefix: -S

  s:
    type: ['null', string]
    doc: The column for segment starts in the region, e.g. exon starts
    inputBinding:
      prefix: -s

  T:
    type: ['null', string]
    doc: Trim bases after [INT] bases in the reads
    inputBinding:
      prefix: -T

  t:
    type: ['null', boolean]
    default: false
    doc: Indicate to remove duplicated reads. Only one pair with same start positions
      will be kept
    inputBinding:
      prefix: -t

  th:
    type: ['null', string]
    doc: Threads count.
    inputBinding:
      prefix: -th

  V:
    type: ['null', string]
    doc: The lowest frequency in normal sample allowed for a putative somatic mutations.
      Default to 0.05
    inputBinding:
      prefix: -V

  VS:
    type: ['null', string]
    doc: How strict to be when reading a SAM or BAM. STRICT - throw an exception if
      something looks wrong. LENIENT - Emit warnings but keep going if possible. SILENT
      - Like LENIENT, only don't emit warning messages. Default - LENIENT
    inputBinding:
      prefix: -VS

  X:
    type: ['null', string]
    default: '5'
    doc: Extension of bp to look for mismatches after insersion or deletion. Default
      to 3 bp, or only calls when they're within 3 bp.
    inputBinding:
      prefix: -X

  x:
    type: ['null', string]
    default: '2000'
    doc: The number of nucleotide to extend for each segment, default - 0 -y
    inputBinding:
      prefix: -x

  Z:
    type: ['null', string]
    doc: For downsampling fraction. e.g. 0.7 means roughly 70%% downsampling. Default
      - No downsampling. Use with caution. The downsampling will be random and non-reproducible.
    inputBinding:
      prefix: -Z

  z:
    type: ['null', string]
    default: '1'
    doc: Indicate wehther is zero-based cooridates, as IGV does. Default - 1 for BED
      file or amplicon BED file. Use 0 to turn it off. When use -R option, it's set
      to 0AUTHOR. Written by Zhongwu Lai, AstraZeneca, Boston, USAREPORTING BUGS.
      Report bugs to zhongwu@yahoo.comCOPYRIGHT. This is free software - you are free
      to change and redistribute it. There is NO WARRANTY, to the extent permitted
      by law.
    inputBinding:
      prefix: -z

  G:
    type:
    - 'null'
    - string
    default: GRCh37

    inputBinding:
      prefix: -G

  vcf:
    type: 

      - 'null'
      - string
    doc: output vcf file
    inputBinding:
      prefix: --vcf


outputs:
  output:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.vcf)
            return inputs.vcf;
          return null;
        }
