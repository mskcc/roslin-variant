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

  hs_metrics:
    type: 
      type: array
      items: File

  insert_metrics:
    type: 
      type: array
      items: File

  per_target_coverage:
    type: 
      type: array
      items: File

  qual_metrics:
    type: 
      type: array
      items: File

  doc_basecounts:
    type: 
      type: array
      items: File

outputs:

  merged_mdmetrics:
    type: File
    outputSource: qc_merge/merged_mdmetrics

  merged_hsmetrics:
    type: File
    outputSource: qc_merge/merged_hsmetrics

  merged_hstmetrics:
    type: File
    outputSource: qc_merge/merged_hstmetrics

  merged_insert_size_histograms:
    type: File
    outputSource: qc_merge/merged_insert_size_histograms

  fingerprints_output:
    type: File[]
    outputSource: qc_merge/fingerprints_output

  fingerprint_summary:
    type: File
    outputSource: qc_merge/fingerprint_summary

  qual_files_r:
    type: File
    outputSource: qc_merge/qual_files_r

  qual_files_o:
    type: File
    outputSource: qc_merge/qual_files_o

  cutadapt_summary:
    type: File
    outputSource: qc_merge/cutadapt_summary

  hs_portal_fillout:
    type: File
    outputSource: hotspots_fillout/portal_fillout

  hs_in_normals:
    type: File
    outputSource: run_hotspots_in_normals/hs_in_normals

  minor_contam_freqlist:
    type: File
    outputSource: run_minor_contam_binlist/minor_contam_freqlist

  qc_merged_directory:
    type: Directory
    outputSource: compiled_output_directory/directory

steps:

  qc_merge:
    run: qc-merge.cwl
    in:
      db_files: db_files
      runparams: runparams
      clstats1: clstats1
      clstats2: clstats2
      md_metrics: md_metrics 
      hs_metrics: hs_metrics
      per_target_coverage: per_target_coverage
      insert_metrics: insert_metrics
      doc_basecounts: doc_basecounts
      qual_metrics: qual_metrics
    out: [ merged_mdmetrics, merged_hsmetrics, merged_hstmetrics, merged_insert_size_histograms, fingerprints_output, fingerprint_summary, minor_contam_output, qual_files_r, qual_files_o, cutadapt_summary ]

  hotspots_fillout:
    run: ../cmo-fillout/1.2.2/cmo-fillout.cwl
    in:
      db_files: db_files
      maf: 
        valueFrom: ${ return inputs.db_files.hotspot_list_maf; }
      aa_bams: bams
      runparams: runparams
      bams:
        valueFrom: ${ var output = [];  for (var i=0; i<inputs.aa_bams.length; i++) { output=output.concat(inputs.aa_bams[i]); } return output; }
      genome:
        valueFrom: ${ return inputs.runparams.genome; }
      output_format:
        valueFrom: ${ return "1"; }
      project_prefix:
        valueFrom: ${ return inputs.runparams.project_prefix; }
    out: [ portal_fillout ]

  run_hotspots_in_normals:
    run: create-hotspots-in-normals.cwl
    in:
      runparams: runparams
      db_files: db_files
      fillout_file: hotspots_fillout/portal_fillout
      project_prefix: 
        valueFrom: ${ return inputs.runparams.project_prefix; }
      pairing_file:
        valueFrom: ${ return inputs.db_files.pairing_file; }
    out: [ hs_in_normals ]

  run_minor_contam_binlist:
    run: create-minor-contam-binlist.cwl
    in:
      runparams: runparams
      minor_contam_file: qc_merge/minor_contam_output
      fp_summary: qc_merge/fingerprint_summary
      min_cutoff:
        default: 0.01
      project_prefix: 
        valueFrom: ${ return inputs.runparams.project_prefix; }
    out: [ minor_contam_freqlist ]

  compiled_output_directory:
    run: ../consolidate-files/consolidate-files.cwl
    in: 
      merged_files: [ qc_merge/merged_mdmetrics, qc_merge/merged_hsmetrics, qc_merge/merged_hstmetrics, qc_merge/merged_insert_size_histograms, qc_merge/fingerprint_summary, qc_merge/minor_contam_output, qc_merge/qual_files_r, qc_merge/qual_files_o, qc_merge/cutadapt_summary, run_hotspots_in_normals/hs_in_normals, run_minor_contam_binlist/minor_contam_freqlist ]
      fp_output: qc_merge/fingerprints_output 
      files: 
         valueFrom: ${ return inputs.merged_files.concat(inputs.fp_output); }
      output_directory_name:
       valueFrom: ${ return "qc_merged_directory"; }
    out: [ directory ]
