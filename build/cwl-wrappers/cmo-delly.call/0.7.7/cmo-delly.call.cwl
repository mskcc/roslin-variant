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
  doap:name: cmo-delly.call
  doap:revision: 0.7.7
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
    foaf:name: Nikhil Kumar
    foaf:mbox: mailto:kumarn1@mskcc.org
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_delly.py -b cmo_delly.py --version default --cmd call --generate_cwl_tool
# Help: $ cmo_delly.py  --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- cmo_delly
- --version
- default
- --cmd
- call

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 7
    coresMin: 2

doc: |
  None

inputs:
  t:
    type: ['null', string]
    default: DEL
    doc: SV type (DEL, DUP, INV, BND, INS)
    inputBinding:
      prefix: --type

  g:
    type:
    - 'null'
    - type: enum
      symbols: [GRCm38, hg19, ncbi36, mm9, GRCh37, mm10, hg18, GRCh38]
    doc: genome fasta file
    inputBinding:
      prefix: --genome

  x:
    type: ['null', string]
    doc: file with regions to exclude
    inputBinding:
      prefix: --exclude

  o:
    type: ['null', string]
    default: sv.bcf
    doc: SV BCF output file
    inputBinding:
      prefix: --outfile

  q:
    type: ['null', int]
    default: 1
    doc: min. paired-end mapping quality
    inputBinding:
      prefix: --map-qual

  s:
    type: ['null', int]
    default: 9
    doc: insert size cutoff, median+s*MAD (deletions only)
    inputBinding:
      prefix: --mad-cutoff

  n:
    type: ['null', boolean]
    default: false
    doc: no small InDel calling
    inputBinding:
      prefix: --noindels

  v:
    type: ['null', string]
    doc: input VCF/BCF file for re-genotyping
    inputBinding:
      prefix: --vcffile

  u:
    type: ['null', int]
    default: 5
    doc: min. mapping quality for genotyping
    inputBinding:
      prefix: --geno-qual

  i:
    type:
      type: array
      items: File
    inputBinding:
      prefix: --input
      itemSeparator: ' '
      separate: true
    secondaryFiles: [.bai]
    doc: Input files (sorted bams)
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


outputs:
  sv_file:
    type: File?
    outputBinding:
      glob: |-
        ${
          if (inputs.o)
            return inputs.o;
          return null;
        }
