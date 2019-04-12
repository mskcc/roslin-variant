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
  - class: foaf:Person
    foaf:name: Nikhil Kumar
    foaf:mbox: mailto:kumarn1@mskcc.org
  - class: foaf:Person
    foaf:name: Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org


cwlVersion: v1.0

class: Workflow
label: project-workflow-sv
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
        project_prefix: string
        opt_dup_pix_dist: string
        facets_pcval: int
        facets_cval: int
        abra_ram_min: int
        delly_type:
          type:
            type: array
            items: string

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

  # vcf
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
  combine_vcf:
    type:
      type: array
      items: File
    outputSource: variant_calling/combine_vcf
    secondaryFiles:
    - .tbi
  # norm vcf
  vardict_norm_vcf:
    type:
      type: array
      items: File
    outputSource: variant_calling/vardict_norm_vcf
    secondaryFiles:
      - .tbi
  mutect_norm_vcf:
    type:
      type: array
      items: File
    outputSource: variant_calling/mutect_norm_vcf
    secondaryFiles:
      - .tbi
  # structural variants
  merged_file_unfiltered:
    type: File[]
    outputSource: find_svs/merged_file_unfiltered
  merged_file:
    type: File[]
    outputSource: find_svs/merged_file
  maf_file:
    type: File[]
    outputSource: find_svs/maf_file
  portal_file:
    type: File[]
    outputSource: find_svs/portal_file

  # facets
  facets_png:
    type:
      type: array
      items:
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
      items:
        type: array
        items: File
    outputSource: variant_calling/facets_out
  facets_rdata:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: variant_calling/facets_rdata
  facets_seg:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: variant_calling/facets_seg
  facets_counts:
    type:
      type: array
      items: File
    outputSource: variant_calling/facets_counts

  # maf
  maf:
    type: File[]
    outputSource: filter/maf

  # qc
  as_metrics:
    type: File[]
    outputSource: gather_metrics/as_metrics
  hs_metrics:
    type: File[]
    outputSource: gather_metrics/hs_metrics
  insert_metrics:
    type: File[]
    outputSource: gather_metrics/insert_metrics
  insert_pdf:
    type: File[]
    outputSource: gather_metrics/insert_pdf
  per_target_coverage:
    type: File[]
    outputSource: gather_metrics/per_target_coverage
  qual_metrics:
    type: File[]
    outputSource: gather_metrics/qual_metrics
  qual_pdf:
    type: File[]
    outputSource: gather_metrics/qual_pdf
  doc_basecounts:
    type: File[]
    outputSource: gather_metrics/doc_basecounts
  gcbias_pdf:
    type: File[]
    outputSource: gather_metrics/gcbias_pdf
  gcbias_metrics:
    type: File[]
    outputSource: gather_metrics/gcbias_metrics
  gcbias_summary:
    type: File[]
    outputSource: gather_metrics/gcbias_summary
  qcpdf:
    type: File[]
    outputSource: gather_metrics/qc_files

  concordance_txt:
    type: File
    outputSource: run_conpair/concordance_txt
  concordance_pdf:
    type: File
    outputSource: run_conpair/concordance_pdf
  contamination_txt:
    type: File
    outputSource: run_conpair/contamination_txt
  contamination_pdf:
    type: File
    outputSource: run_conpair/contamination_pdf
  cdna_contam_output:
    type: File?
    outputSource: run_cdna_contam_check/cdna_contam_output

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
      refseq: projparse/refseq
      group: projparse/group_ids
      opt_dup_pix_dist: projparse/opt_dup_pix_dist
    out: [clstats1, clstats2, bams, md_metrics, covint_bed, covint_list]
    scatter: [fastq1,fastq2,adapter,adapter2,bwa_output,add_rg_LB,add_rg_PL,add_rg_ID,add_rg_PU,add_rg_SM,add_rg_CN, tmp_dir, abra_scratch, dbsnp, hapmap, indels_1000g, cosmic, snps_1000g, mutect_dcov, mutect_rf, abra_scratch, refseq, covariates, group]
    scatterMethod: dotproduct

  pairing:
    run: sort-bams-by-pair/1.0.0/sort-bams-by-pair.cwl
    in:
      bams: group_process/bams
      pairs: pairs
      db_files: db_files
      dbsnp_inputs: dbsnp
      hapmap_inputs: hapmap
      cosmic_inputs: cosmic
      snps_1000g_inputs: snps_1000g
      indels_1000g_inputs: indels_1000g
      runparams: runparams
      beds: group_process/covint_bed
    out: [tumor_bams, normal_bams, tumor_sample_ids, normal_sample_ids, dbsnp, cosmic, mutect_dcov, mutect_rf, refseq, genome, facets_pcval, facets_cval, covint_bed, vep_data, delly_type ]

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
    out: [combine_vcf, annotate_vcf, facets_png, facets_txt_hisens, facets_txt_purity, facets_out, facets_rdata, facets_seg, facets_counts, mutect_vcf, mutect_callstats, vardict_vcf, vardict_norm_vcf, mutect_norm_vcf]
    scatter: [tumor_bam, normal_bam, normal_sample_name, tumor_sample_name, genome, facets_pcval, facets_cval, dbsnp, cosmic, refseq, mutect_rf, mutect_dcov, bed]
    scatterMethod: dotproduct

  parse_pairs:
    run: parse-pairs-and-vcfs/2.0.0/parse-pairs-and-vcfs.cwl
    in:
      bams: group_process/bams
      pairs: pairs
      annotate_vcf: variant_calling/annotate_vcf
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

  gather_metrics:
    run: module-5.cwl
    in:
      aa_bams: group_process/bams
      bams:
        valueFrom: ${ var output = [];  for (var i=0; i<inputs.aa_bams.length; i++) { output=output.concat(inputs.aa_bams[i]); } return output; }
      genome: projparse/genome
      bait_intervals: projparse/bait_intervals
      target_intervals: projparse/target_intervals
      fp_intervals: projparse/fp_intervals
      fp_genotypes: projparse/fp_genotypes
      conpair_markers: projparse/conpair_markers
      conpair_markers_bed: projparse/conpair_markers_bed
      md_metrics_files: group_process/md_metrics
      clstats1: group_process/clstats1
      clstats2: group_process/clstats2
      trim_metrics_files: [ group_process/clstats1, group_process/clstats2]
      project_prefix: projparse/project_prefix
      grouping_file: projparse/grouping_file
      request_file: projparse/request_file
      pairing_file: projparse/pairing_file
    out: [ as_metrics, hs_metrics, insert_metrics, insert_pdf, per_target_coverage, qual_metrics, qual_pdf, doc_basecounts, gcbias_pdf, gcbias_metrics, gcbias_summary, qc_files ]

  run_conpair:
    run: conpair/0.2/conpair-master.cwl
    in:
      ref: projparse/ref_fasta_string
      markers: projparse/conpair_markers
      markers_bed: projparse/conpair_markers_bed
      tumor_bams: pairing/tumor_bams
      normal_bams: pairing/normal_bams
      tumor_sample_name: pairing/tumor_sample_ids
      normal_sample_name: pairing/normal_sample_ids
      file_prefix: projparse/project_prefix
      pairing_file: projparse/pairing_file
    out: [ concordance_txt, concordance_pdf, contamination_txt, contamination_pdf ]

  find_svs:
    run: module-6.cwl
    in:
      tumor_bam: pairing/tumor_bams
      normal_bam: pairing/normal_bams
      genome: pairing/genome
      vep_data: pairing/vep_data
      normal_sample_name: pairing/normal_sample_ids
      tumor_sample_name: pairing/tumor_sample_ids
      delly_type: pairing/delly_type
    out: [ merged_file, merged_file_unfiltered, maf_file, portal_file ]
    scatter: [ tumor_bam, normal_bam, genome,normal_sample_name, tumor_sample_name, delly_type, vep_data ]
    scatterMethod: dotproduct

  run_cdna_contam_check:
    run: roslin-qc/create-cdna-contam.cwl
    in:
      runparams: runparams
      input_mafs: find_svs/maf_file
      project_prefix:
        valueFrom: ${ return inputs.runparams.project_prefix; }
    out: [ cdna_contam_output ]
