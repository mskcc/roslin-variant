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
  doap:name: gather-metrics
  doap:revision: 1.0.0
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: C. Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org

cwlVersion: v1.0

class: Workflow
id: gather-metrics
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
        vep_path: string
        custom_enst: string
        vep_data: string
        hotspot_list: string
        hotspot_list_maf: File
        hotspot_vcf: string
        facets_snps: string
        bait_intervals: File
        target_intervals: File
        fp_intervals: File
        fp_genotypes: File
        conpair_markers: string
        conpair_markers_bed: string
        grouping_file: File
        request_file: File
        pairing_file: File

  pairs:
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
        scripts_bin: string

  bams:
    type:
      type: array
      items:
        type: array
        items: File
    secondaryFiles: ^.bai

  clstats1:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: File

  clstats2:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: File

  md_metrics:
    type:
      type: array
      items:
        type: array
        items: File

outputs:

  as_metrics:
    type:
      type: array
      items: File
    outputSource: gather_metrics/as_metrics
  hs_metrics:
    type:
      type: array
      items: File
    outputSource: gather_metrics/hs_metrics
  insert_metrics:
    type:
      type: array
      items: File
    outputSource: gather_metrics/insert_metrics
  insert_pdf:
    type:
      type: array
      items: File
    outputSource: gather_metrics/insert_pdf
  per_target_coverage:
    type:
      type: array
      items: File
    outputSource: gather_metrics/per_target_coverage
  qual_metrics:
    type:
      type: array
      items: File
    outputSource: gather_metrics/qual_metrics
  qual_pdf:
    type:
      type: array
      items: File
    outputSource: gather_metrics/qual_pdf
  doc_basecounts:
    type:
      type: array
      items: File
    outputSource: gather_metrics/doc_basecounts
  gcbias_pdf:
    type:
      type: array
      items: File
    outputSource: gather_metrics/gcbias_pdf
  gcbias_metrics:
    type:
      type: array
      items: File
    outputSource: gather_metrics/gcbias_metrics
  gcbias_summary:
    type:
      type: array
      items: File
    outputSource: gather_metrics/gcbias_summary

  # qc
  gather_metrics_files:
    type: Directory
    outputSource: compile_intermediates_directory/directory
   
  qc_merged_and_hotspots_directory:
    type: Directory
    outputSource: qc_merge_and_hotspots/qc_merged_directory

steps:

  gather_metrics:
    run: module-5.cwl
    in:
      aa_bams: bams
      runparams: runparams
      db_files: db_files
      bams:
        valueFrom: ${ var output = [];  for (var i=0; i<inputs.aa_bams.length; i++) { output=output.concat(inputs.aa_bams[i]); } return output; }
      genome:
        valueFrom: ${ return inputs.runparams.genome; }
      bait_intervals:
        valueFrom: ${ return inputs.db_files.bait_intervals; }
      target_intervals:
        valueFrom: ${ return inputs.db_files.target_intervals; }
      fp_intervals:
        valueFrom: ${ return inputs.db_files.fp_intervals; }
      md_metrics_files: md_metrics
      clstats1: clstats1
      clstats2: clstats2
      tmp_dir:
        valueFrom: ${ return inputs.runparams.tmp_dir; }
    out: [ as_metrics, hs_metrics, insert_metrics, insert_pdf, per_target_coverage, qual_metrics, qual_pdf, doc_basecounts, gcbias_pdf, gcbias_metrics, gcbias_summary ]

  compile_intermediates_directory:
    run: ./consolidate-files/consolidate-files.cwl
    in:
      md_metrics: md_metrics
      data_files: [ gather_metrics/hs_metrics, gather_metrics/per_target_coverage, gather_metrics/insert_metrics, gather_metrics/doc_basecounts, gather_metrics/qual_metrics ]
      files:
        valueFrom: ${ return inputs.data_files.flat().concat(inputs.md_metrics.flat()); }
      output_directory_name:
        valueFrom: ${ return "gather_metrics_files"; }
    out: [ directory ]

  qc_merge_and_hotspots:
    run: ./roslin-qc/qc-merge-and-hotspots.cwl
    in:
      aa_bams: bams
      runparams: runparams
      db_files: db_files
      clstats1: clstats1
      clstats2: clstats2
      bams:
        valueFrom: ${ var output = [];  for (var i=0; i<inputs.aa_bams.length; i++) { output=output.concat(inputs.aa_bams[i]); } return output; }
      hs_metrics: gather_metrics/hs_metrics
      md_metrics: md_metrics
      per_target_coverage: gather_metrics/per_target_coverage
      insert_metrics: gather_metrics/insert_metrics
      doc_basecounts: gather_metrics/doc_basecounts
      qual_metrics: gather_metrics/qual_metrics
    out: [ qc_merged_directory ]
