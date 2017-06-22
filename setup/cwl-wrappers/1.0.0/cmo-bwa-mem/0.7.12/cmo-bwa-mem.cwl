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
  doap:name: cmo-bwa-mem
  doap:revision: 0.7.12
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
# To generate again: $ cmo_bwa_mem -o FILENAME --generate_cwl_tool
# Help: $ cmo_bwa_mem  --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand: [cmo_bwa_mem]

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 30
    coresMin: 5

doc: |
  run bwa mem

inputs:
  genome:
    type:
      type: enum
      symbols: [GRCm38, hg19, ncbi36, mm9, GRCh37, mm10, hg18, GRCh38]
    inputBinding:
      prefix: --genome

  fastq1:
    type: 


      - string
      - File
    inputBinding:
      prefix: --fastq1

  fastq2:
    type:
    - string
    - File
    inputBinding:
      prefix: --fastq2

  output:
    type: string


    inputBinding:
      prefix: --output

  sam:
    type: ['null', boolean]
    default: false
    doc: Produce Sam instead of the default bam (Boolean)
    inputBinding:
      prefix: --sam

  version:
    type:
      type: enum
      symbols: [default]
    inputBinding:
      prefix: --version

    default: default
  E:
    type: ['null', string]
    doc: INT[,INT] gap extension penalty; a gap of size k cost '{-O} + {-E}*k' [1,1]
    inputBinding:
      prefix: -E

  D:
    type: ['null', string]
    doc: FLOAT drop chains shorter than FLOAT fraction of the longest overlapping
      chain [0.50]
    inputBinding:
      prefix: -D

  A:
    type: ['null', string]
    doc: INT score for a sequence match, which scales options -TdBOELU unless overridden
      [1]
    inputBinding:
      prefix: -A

  C:
    type: ['null', boolean]
    default: false
    doc: append FASTA/FASTQ comment to SAM output
    inputBinding:
      prefix: -C

  B:
    type: ['null', string]
    doc: INT penalty for a mismatch [4]
    inputBinding:
      prefix: -B

  M:
    type: ['null', boolean]
    default: false
    doc: mark shorter split hits as secondary
    inputBinding:
      prefix: -M

  L:
    type: ['null', string]
    doc: INT[,INT] penalty for 5'- and 3'-end clipping [5,5]
    inputBinding:
      prefix: -L

  O:
    type: ['null', string]
    doc: INT[,INT] gap open penalties for deletions and insertions [6,6]
    inputBinding:
      prefix: -O

  I:
    type: ['null', string]
    doc: FLOAT[,FLOAT[,INT[,INT]]]
    inputBinding:
      prefix: -I

  H:
    type: ['null', string]
    doc: STR/FILE insert STR to header if it starts with @; or insert lines in FILE
      [null]
    inputBinding:
      prefix: -H

  U:
    type: ['null', string]
    doc: INT penalty for an unpaired read pair [17]
    inputBinding:
      prefix: -U

  T:
    type: ['null', string]
    doc: INT minimum score to output [30]
    inputBinding:
      prefix: -T

  W:
    type: ['null', string]
    doc: INT discard a chain if seeded bases shorter than INT [0]
    inputBinding:
      prefix: -W

  V:
    type: ['null', boolean]
    default: false
    doc: output the reference FASTA header in the XR tag
    inputBinding:
      prefix: -V

  P:
    type: ['null', boolean]
    default: false
    doc: skip pairing; mate rescue performed unless -S also in use
    inputBinding:
      prefix: -P

  S:
    type: ['null', boolean]
    default: false
    doc: skip mate rescue
    inputBinding:
      prefix: -S

  R:
    type: ['null', string]
    doc: STR read group header line such as '@RG\tID -foo\tSM -bar' [null]
    inputBinding:
      prefix: -R

  Y:
    type: ['null', boolean]
    default: false
    doc: use soft clipping for supplementary alignments
    inputBinding:
      prefix: -Y

  e:
    type: ['null', boolean]
    default: false
    doc: discard full-length exact matches
    inputBinding:
      prefix: -e

  d:
    type: ['null', string]
    doc: INT off-diagonal X-dropoff [100]
    inputBinding:
      prefix: -d

  a:
    type: ['null', boolean]
    default: false
    doc: output all alignments for SE or unpaired PE
    inputBinding:
      prefix: -a

  c:
    type: ['null', string]
    doc: INT skip seeds with more than INT occurrences [500]
    inputBinding:
      prefix: -c

  m:
    type: ['null', string]
    doc: INT perform at most INT rounds of mate rescues for each read [50]
    inputBinding:
      prefix: -m

  k:
    type: ['null', string]
    doc: INT minimum seed length [19]
    inputBinding:
      prefix: -k

  j:
    type: ['null', boolean]
    default: false
    doc: treat ALT contigs as part of the primary assembly (i.e. ignore <idxbase>.alt
      file)
    inputBinding:
      prefix: -j

  t:
    type: ['null', string]
    doc: INT number of threads [1]
    inputBinding:
      prefix: -t

    default: '5'
  w:
    type: ['null', string]
    doc: INT band width for banded alignment [100]
    inputBinding:
      prefix: -w

  v:
    type: ['null', string]
    doc: INT verbose level - 1=error, 2=warning, 3=message, 4+=debugging [3]
    inputBinding:
      prefix: -v

  p:
    type: ['null', string]
    doc: smart pairing (ignoring in2.fq)
    inputBinding:
      prefix: -p

  r:
    type: ['null', string]
    doc: FLOAT look for internal seeds inside a seed longer than {-k} * FLOAT [1.5]
    inputBinding:
      prefix: -r

  y:
    type: ['null', string]
    doc: INT seed occurrence for the 3rd round seeding [20]
    inputBinding:
      prefix: -y

  x:
    type: ['null', string]
    doc: STR read type. Setting -x changes multiple parameters unless overriden [null]
    inputBinding:
      prefix: -x

  hh:
    type: ['null', string]
    doc: INT[,INT] if there are <INT hits with score >80%% of the max score, output
      all in XA [5,200]
    inputBinding:
      prefix: -hh


outputs:
  bam:
    type: File
    outputBinding:
      glob: |-
        ${
          if (inputs.output)
            return inputs.output;
          return null;
        }
