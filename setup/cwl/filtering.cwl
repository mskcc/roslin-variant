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
        refseq: File
        ref_fasta: string
        vep_data: string
        hotspot_list: File
        hotspot_vcf: File
        bait_intervals: File
        target_intervals: File
        fp_intervals: File
        fp_genotypes: File
        conpair_markers: File
        conpair_markers_bed: File
        grouping_file: File
        request_file: File
        pairing_file: File
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
      items: string
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
        complex_tn: int
        complex_nn: int
        delly_type:
          type:
            type: array
            items: string
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

  bams:
    type:
      type: array
      items:
        type: array
        items: File
    secondaryFiles: ^.bai

  covint_bed:
    type:
      type: array
      items: File

  annotate_vcf:
    type:
      type: array
      items: File

outputs:

  # maf
  maf:
    type: File[]
    outputSource: filter/maf

steps:

  projparse:
    run: parse-project-yaml-input/1.0.1/parse-project-yaml-input.cwl
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
    out: [R1, R2, adapter, adapter2, bwa_output, LB, PL, RG_ID, PU, ID, CN, genome, tmp_dir, abra_scratch, cosmic, covariates, dbsnp, hapmap, indels_1000g, mutect_dcov, mutect_rf, refseq, snps_1000g, ref_fasta, exac_filter, vep_data, curated_bams, hotspot_list, hotspot_vcf, group_ids, target_intervals, bait_intervals, fp_intervals, fp_genotypes, conpair_markers, conpair_markers_bed, request_file, pairing_file, grouping_file, project_prefix, opt_dup_pix_dist, ref_fasta_string]

  pairing:
    run: sort-bams-by-pair/1.0.0/sort-bams-by-pair.cwl
    in:
      bams: bams
      pairs: pairs
      db_files: db_files
      dbsnp_inputs: dbsnp
      hapmap_inputs: hapmap
      cosmic_inputs: cosmic
      snps_1000g_inputs: snps_1000g
      indels_1000g_inputs: indels_1000g
      runparams: runparams
      beds: covint_bed
    out: [tumor_bams, normal_bams, tumor_sample_ids, normal_sample_ids, dbsnp, cosmic, mutect_dcov, mutect_rf, refseq, genome, covint_bed, facets_pcval, facets_cval]

  parse_pairs:
    run: parse-pairs-and-vcfs/2.0.0/parse-pairs-and-vcfs.cwl
    in:
      bams: bams
      pairs: pairs
      annotate_vcf: annotate_vcf
      genome: projparse/genome
      exac_filter: projparse/exac_filter
      ref_fasta: projparse/ref_fasta
      vep_data: projparse/vep_data
      curated_bams: projparse/curated_bams
      hotspot_list: projparse/hotspot_list
      groups: groups
    out: [tumor_id, normal_id, srt_genome, srt_annotate_vcf, srt_ref_fasta, srt_exac_filter, srt_vep_data, srt_bams, srt_curated_bams, srt_hotspot_list]

  filter:
    run: module-4.cwl
    in:
      bams: parse_pairs/srt_bams
      annotate_vcf: parse_pairs/srt_annotate_vcf
      db_files: db_files
      runparams: runparams
      genome: parse_pairs/srt_genome
      ref_fasta: parse_pairs/srt_ref_fasta
      exac_filter: parse_pairs/srt_exac_filter
      vep_data: parse_pairs/srt_vep_data
      tumor_sample_name: parse_pairs/tumor_id
      normal_sample_name: parse_pairs/normal_id
      curated_bams: parse_pairs/srt_curated_bams
      hotspot_list: parse_pairs/srt_hotspot_list
    out: [maf]
    scatter: [bams, annotate_vcf, tumor_sample_name, normal_sample_name, ref_fasta, exac_filter, vep_data]
    scatterMethod: dotproduct
