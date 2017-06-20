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
  doap:name: project-workflow
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
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:
  db_files:
    type:
      type: record
      fields:
        cosmic: File
        dbsnp: File
        hapmap: File
        indels_1000g: File
        refseq: File
        snps_1000g: File
  groups:
    type:
      type: array
      items:
        type: array
        items: string
  runparams:
    type:
      type: record
      fields:
        abra_scratch: string
        covariates:
          type:
            type: array
            items: string
        emit_original_quals: boolean
        genome: string
        intervals: string
        mutect_dcov: int
        mutect_rf:
          type:
            type: array
            items: string
        num_cpu_threads_per_data_thread: int
        num_threads: int
        sid_rf:
          type:
            type: array
            items: string
        tmp_dir: string
  samples:
    type:
      type: array
      items:
        type: record
        fields:
          CN: string
          LB: string
          ID: string
          PL: string
          PU: string
          R1:
            type:
              type: array
              items: File
          R2:
            type:
              type: array
              items: File
          RG_ID: string
          adapter: string
          adapter2: string
          bwa_output: string
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
    outputSource: group_process/bams
  clstats1:
    type:
      type: array
      items: File
    outputSource: group_process/clstats1
  clstats2:
    type:
      type: array
      items: File
    outputSource: group_process/clstats2
  md_metrics:
    type:
      type: array
      items: File
    outputSource: group_process/md_metrics
  mutect_vcf:
    type:
      type: array
      items: File
    outputSource: group_process/mutect_vcf
  mutect_callstats:
    type:
      type: array
      items: File
    outputSource: group_process/mutect_callstats
  somaticindeldetector_vcf:
    type:
      type: array
      items: File
    outputSource: group_process/somaticindeldetector_vcf
  somaticindeldetector_verbose_vcf:
    type:
      type: array
      items: File
    outputSource: group_process/somaticindeldetector_verbose_vcf
  vardict_vcf:
    type:
      type: array
      items: File
    outputSource: group_process/vardict_vcf
  pindel_vcf:
    type:
      type: array
      items: File
    outputSource: group_process/pindel_vcf

steps:
  projparse:
    run: parse-project-yaml-input/1.0.0/parse-project-yaml-input.cwl
    in:
      db_files: db_files
      groups: groups
      pairs: pairs
      samples: samples
      runparams: runparams
    out: [R1, R2, adapter, adapter2, bwa_output, LB, PL, RG_ID, PU, ID, CN, grouppairs, genome, tmp_dir, abra_scratch, cosmic, covariates, dbsnp, hapmap, indels_1000g, mutect_dcov, mutect_rf, refseq, sid_rf, snps_1000g]
  group_process:
    run:  module-1-2-3.chunk.cwl
    in:
      fastq1: projparse/R1
      fastq2: projparse/R2
      adapter: projparse/adapter
      adapter2: projparse/adapter2
      bwa_output: projparse/bwa_output
      add_rg_LB: projparse/LB
      add_rg_PL: projparse/PL
      add_rg_ID: projparse/RG_ID
      add_rg_PU: projparse/PU
      add_rg_SM: projparse/ID
      add_rg_CN: projparse/CN
      tmp_dir: projparse/tmp_dir
      pairs: projparse/grouppairs
      hapmap: projparse/hapmap
      dbsnp: projparse/dbsnp
      indels_1000g: projparse/indels_1000g
      cosmic: projparse/cosmic
      snps_1000g: projparse/snps_1000g
      genome: projparse/genome
      mutect_dcov: projparse/mutect_dcov
      mutect_rf: projparse/mutect_rf
      covariates: projparse/covariates
      abra_scratch: projparse/abra_scratch
      sid_rf: projparse/sid_rf
      refseq: projparse/refseq
    out: [clstats1, clstats2, bams, md_metrics, mutect_vcf, mutect_callstats, somaticindeldetector_vcf, somaticindeldetector_verbose_vcf, vardict_vcf, pindel_vcf]
    scatter: [fastq1,fastq2,adapter,adapter2,bwa_output,add_rg_LB,add_rg_PL,add_rg_ID,add_rg_PU,add_rg_SM,add_rg_CN, pairs, tmp_dir, genome, abra_scratch, dbsnp, indels_1000g, cosmic, snps_1000g, mutect_dcov, mutect_rf, abra_scratch, sid_rf, refseq, covariates]
    scatterMethod: dotproduct

