#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- file:///ifs/work/pi/roslin-test/targeted-variants/285/roslin-core/2.0.0/schemas/dcterms.rdf
- file:///ifs/work/pi/roslin-test/targeted-variants/285/roslin-core/2.0.0/schemas/foaf.rdf
- file:///ifs/work/pi/roslin-test/targeted-variants/285/roslin-core/2.0.0/schemas/doap.rdf

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
  - class: foaf:Person
    foaf:name: Nikhil Kumar
    foaf:mbox: mailto:kumarn1@mskcc.org
  - class: foaf:Person
    foaf:name: Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org


cwlVersion: v1.0

class: Workflow
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  db_files:
    type:
      type: record
      fields:
        bait_intervals: File
        refseq: File
        ref_fasta: string
        vep_data: string
        hotspot_list: File
        hotspot_vcf: File
        target_intervals: File
        fp_intervals: File
        fp_genotypes: File
        grouping_file: File
        request_file: File
        pairing_file: File
        conpair_markers: File
        conpair_markers_bed: File
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
  exac_filter:
    type: File
    secondaryFiles:
      - .tbi
  curated_bams:
    type:
      type: array
      items: File
    secondaryFiles:
      - ^.bai

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
        mutect_dcov: int
        mutect_rf:
          type:
            type: array
            items: string
        num_cpu_threads_per_data_thread: int
        num_threads: int
        tmp_dir: string
        project_prefix: string
        opt_dup_pix_dist: string
        facets_pcval: int
        facets_cval: int
        abra_ram_min: int
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
          PU: string[]
          R1: string[]
          R2: string[]
          RG_ID: string[]
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

  # bams & metrics
  bams:
    type:
      type: array
      items:
        type: array
        items: File
    secondaryFiles:
      - ^.bai
    outputSource: group_process/bams
  clstats1:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: File
    outputSource: group_process/clstats1
  clstats2:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: File
    outputSource: group_process/clstats2
  md_metrics:
    type:
      type: array
      items: 
        type: array
        items: File
    outputSource: group_process/md_metrics
  covint_bed: 
    type:
      type: array
      items: File
    outputSource: group_process/covint_bed
  covint_list: 
    type:
      type: array
      items: File 
    outputSource: group_process/covint_list

steps:

  projparse:
    run: parse-project-yaml-input/1.0.2/parse-project-yaml-input.cwl
    in:
      db_files: db_files
      hapmap_inputs: hapmap
      dbsnp_inputs: dbsnp
      indels_1000g_inputs: indels_1000g
      snps_1000g_inputs: snps_1000g
      exac_filter_inputs: exac_filter
      curated_bams_inputs: curated_bams
      cosmic_inputs: cosmic
      groups: groups
      pairs: pairs
      samples: samples
      runparams: runparams
    out: [r1, r2, adapter, adapter2, bwa_output, lb, pl, rg_id, pu, id, cn, genome, tmp_dir, abra_scratch, abra_ram_min, cosmic, covariates, dbsnp, hapmap, indels_1000g, mutect_dcov, mutect_rf, refseq, snps_1000g, ref_fasta, exac_filter, vep_data, curated_bams, hotspot_list, hotspot_vcf, group_ids, target_intervals, bait_intervals, fp_intervals, fp_genotypes, request_file, pairing_file, grouping_file, project_prefix, opt_dup_pix_dist, ref_fasta_string]


  group_process:
    run:  module-1-2.chunk.cwl
    in:
      runparams: runparams
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
      abra_ram_min: projparse/abra_ram_min
      refseq: projparse/refseq
      group: projparse/group_ids
      opt_dup_pix_dist: projparse/opt_dup_pix_dist
    out: [clstats1, clstats2, bams, md_metrics, covint_bed, covint_list]
    scatter: [fastq1,fastq2,adapter,adapter2,bwa_output,add_rg_LB,add_rg_PL,add_rg_ID,add_rg_PU,add_rg_SM,add_rg_CN, tmp_dir, abra_scratch, dbsnp, hapmap, indels_1000g, cosmic, snps_1000g, mutect_dcov, mutect_rf, abra_scratch, refseq, covariates, group]
    scatterMethod: dotproduct
