#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- file:///ifs/work/pi/roslin-test/targeted-variants/326/roslin-core/2.0.5/schemas/dcterms.rdf
- file:///ifs/work/pi/roslin-test/targeted-variants/326/roslin-core/2.0.5/schemas/foaf.rdf
- file:///ifs/work/pi/roslin-test/targeted-variants/326/roslin-core/2.0.5/schemas/doap.rdf

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
        refseq: File
        ref_fasta: string
        vep_data: string
        exac_filter:
          type: File
          secondaryFiles:
            - .tbi
        hotspot_list: File
        hotspot_vcf: File
        curated_bams:
          type:
            type: array
            items: File
          secondaryFiles:
              - ^.bai
        bait_intervals: File
        target_intervals: File
        fp_intervals: File
        fp_genotypes: File
        conpair_markers: File
        conpair_markers_bed: File
        grouping_file: File
        request_file: File
        pairing_file: File

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

  # vcf
  combine_vcf:
    type:
      type: array
      items: File
    outputSource: variant_calling/combine_vcf
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

  # facets
  facets_png:
    type:
      type: array
      items: File
    outputSource: variant_calling/facets_png
  facets_txt_hisens:
    type:
      type: array
      items: File
    outputSource: variant_calling/facets_txt_hisens
  facets_txt_purity:
    type:
      type: array
      items: File
    outputSource: variant_calling/facets_txt_purity
  facets_out:
    type:
      type: array
      items: File
    outputSource: variant_calling/facets_out
  facets_rdata:
    type:
      type: array
      items: File
    outputSource: variant_calling/facets_rdata
  facets_seg:
    type:
      type: array
      items: File
    outputSource: variant_calling/facets_seg
  facets_counts:
    type:
      type: array
      items: File
    outputSource: variant_calling/facets_counts

steps:

  pairing:
    run: sort-bams-by-pair/1.0.0/sort-bams-by-pair.cwl
    in:
      bams: bams
      pairs: pairs
      db_files: db_files
      runparams: runparams
      beds: covint_bed
    out: [ tumor_bams, normal_bams, tumor_sample_ids, normal_sample_ids, dbsnp, cosmic, mutect_dcov, mutect_rf, refseq, genome, covint_bed, facets_pcval, facets_cval ]

  variant_calling:
    run: module-3.cwl
    in:
      runparams: runparams
      db_files: db_files
      tumor_bam: pairing/tumor_bams
      normal_bam: pairing/normal_bams
      genome: pairing/genome
      bed: pairing/covint_bed
      normal_sample_name: pairing/normal_sample_ids
      tumor_sample_name: pairing/tumor_sample_ids
      dbsnp: pairing/dbsnp
      cosmic: pairing/cosmic
      mutect_dcov: pairing/mutect_dcov
      mutect_rf: pairing/mutect_rf
      refseq: pairing/refseq
      hotspot_vcf: projparse/hotspot_vcf
      ref_fasta: projparse/ref_fasta_string
      facets_pcval: pairing/facets_pcval
      facets_cval: pairing/facets_cval
    out: [combine_vcf, facets_png, facets_txt_hisens, facets_txt_purity, facets_out, facets_rdata, facets_seg, mutect_vcf, mutect_callstats, vardict_vcf, pindel_vcf, facets_counts]
    scatter: [tumor_bam, normal_bam, normal_sample_name, tumor_sample_name, genome, facets_pcval, facets_cval, dbsnp, cosmic, refseq, mutect_rf, mutect_dcov, bed]
    scatterMethod: dotproduct
