#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- file:///ifs/work/chunj/prism-proto/prism/schemas/dcterms.rdf
- file:///ifs/work/chunj/prism-proto/prism/schemas/foaf.rdf
- file:///ifs/work/chunj/prism-proto/prism/schemas/doap.rdf

doap:name: module-1-2-3.cwl
doap:release:
- class: doap:Version
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
        items: File
  fastq2:
    type:
      type: array
      items:
        type: array
        items: File
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
      items: string
  add_rg_PU:
    type:
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
  tmp_dir: string[]
  genome: string[]
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
  mutect_dcov: int
  mutect_rf: string[]
  covariates: string[]
  abra_scratch: string
  intervals: string
  sid_rf:
    type:
      type: array
      items: string
  refseq: File
  pairs:
    type:
      type: array
      items:
        type: array
        items: string

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
      items: File
    outputSource: mapping/clstats1
  clstats2:
    type:
      type: array
      items: File
    outputSource: mapping/clstats2
  md_metrics:
    type:
      type: array
      items: File
    outputSource: mapping/md_metrics
  mutect_vcf:
    type:
      type: array
      items: File
    outputSource: variant_calling/mutect_vcf
  mutect_callstats:
    type:
      type: array
      items: File
    outputSource: variant_calling/mutect_callstats
  somaticindeldetector_vcf:
    type:
      type: array
      items: File
    outputSource: variant_calling/somaticindeldetector_vcf
  somaticindeldetector_verbose_vcf:
    type:
      type: array
      items: File
    outputSource: variant_calling/somaticindeldetector_verbose_vcf
  vardict_vcf:
    type:
      type: array
      items: File
    outputSource: variant_calling/vardict_vcf
  pindel_vcf:
    type:
      type: array
      items: File
    outputSource: variant_calling/pindel_vcf

steps:

  mapping:
    run:  module-1.scatter.chunk.cwl
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
      genome: genome
    out: [outbams, covint_list, covint_bed]
  pairing:
    run: sort-bams-by-pair/1.0.0/sort-bams-by-pair.cwl
    in:
      bams: realignment/outbams
      pairs: pairs
    out: [tumor_bams, normal_bams, tumor_sample_ids, normal_sample_ids]
  variant_calling:
    run: module-3.cwl
    in:
      tumor_bam: pairing/tumor_bams
      normal_bam: pairing/normal_bams
      genome: genome
      bed: realignment/covint_bed
      normal_sample_id: pairing/normal_sample_ids
      tumor_sample_id: pairing/tumor_sample_ids
      dbsnp: dbsnp
      cosmic: cosmic
      mutect_dcov: mutect_dcov
      mutect_rf: mutect_rf
      sid_rf: sid_rf
      refseq: refseq
    out: [somaticindeldetector_vcf, somaticindeldetector_verbose_vcf, mutect_vcf, mutect_callstats, vardict_vcf, pindel_vcf]
    scatter: [tumor_bam, normal_bam, normal_sample_id, tumor_sample_id]
    scatterMethod: dotproduct
