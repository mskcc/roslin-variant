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
  doap:name: module-1-2.chunk
  doap:revision: 1.0.0
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Christopher Harris
    foaf:mbox: mailto:harrisc2@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Christopher Harris
    foaf:mbox: mailto:harrisc2@mskcc.org
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

cwlVersion: v1.0

class: Workflow
label: module-1-2-chunk
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:

  fastq1:
    type:
      type: array
      items:
        type: array
        items: string
  fastq2:
    type:
      type: array
      items:
        type: array
        items: string
  adapter:
    type:
      type: array
      items: string
  adapter2:
    type:
      type: array
      items: string
  bwa_output:
    type:
      type: array
      items: string
  add_rg_LB:
    type:
      type: array
      items: string
  add_rg_PL:
    type:
      type: array
      items: string
  add_rg_ID:
    type:
      type: array
      items:
        type: array
        items: string
  add_rg_PU:
    type:
      type: array
      items:
        type: array
        items: string
  add_rg_SM:
    type:
      type: array
      items: string
  add_rg_CN:
    type:
      type: array
      items: string
  tmp_dir: string
  genome: string
  hapmap:
    type: File
    secondaryFiles:
       - .idx
  dbsnp:
    type: File
    secondaryFiles:
       - .idx
  indels_1000g:
    type: File
    secondaryFiles:
       - .idx
  snps_1000g:
    type: File
    secondaryFiles:
       - .idx
  cosmic:
    type: File
    secondaryFiles:
       - .idx
  abra_ram_min: int
  group: string[]
  mutect_dcov: int
  mutect_rf: string[]
  covariates: string[]
  abra_scratch: string
  intervals: ['null', string]
  refseq: File
  opt_dup_pix_dist: string

outputs:

  bams:
    type:
      type: array
      items: File
    secondaryFiles:
      - ^.bai
    outputSource: realignment/outbams
  clstats1:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: mapping/clstats1
  clstats2:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: mapping/clstats2
  md_metrics:
    type:
      type: array
      items: File
    outputSource: mapping/md_metrics
  covint_list:
    type: File
    outputSource: realignment/covint_list
  covint_bed:
    type: File
    outputSource: realignment/covint_bed

steps:
  mapping:
    run: module-1.scatter.chunk.cwl
    in:
      fastq1: fastq1
      fastq2: fastq2
      adapter: adapter
      adapter2: adapter2
      bwa_output: bwa_output
      genome: genome
      add_rg_LB: add_rg_LB
      add_rg_PL: add_rg_PL
      add_rg_ID: add_rg_ID
      add_rg_PU: add_rg_PU
      add_rg_SM: add_rg_SM
      add_rg_CN: add_rg_CN
      tmp_dir: tmp_dir
      group: group
      opt_dup_pix_dist: opt_dup_pix_dist
    out: [clstats1, clstats2, bam, md_metrics]
    scatter: [fastq1,fastq2,adapter,adapter2,bwa_output,add_rg_LB,add_rg_PL,add_rg_ID,add_rg_PU,add_rg_SM,add_rg_CN]
    scatterMethod: dotproduct
  realignment:
    run: module-2.cwl
    in:
      bams: mapping/bam
      hapmap: hapmap
      dbsnp: dbsnp
      indels_1000g: indels_1000g
      snps_1000g: snps_1000g
      covariates: covariates
      abra_scratch: abra_scratch
      abra_min: abra_min
      group: group
      genome: genome
    out: [outbams, covint_list, covint_bed]
