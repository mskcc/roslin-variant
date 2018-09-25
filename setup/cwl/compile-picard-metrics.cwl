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
  compiled_metrics_data:
    type: Directory
    outputSource: compile_directory_for_qcpdf/directory
  generated_pdf:
    type: File[]
    outputSource: generate_pdf/output
  generated_pdf_images_artifact_directory:
    type: Directory
    outputSource: generate_pdf/images_directory

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
    out: [ as_metrics, hs_metrics, insert_metrics, insert_pdf, per_target_coverage, qual_metrics, qual_pdf, doc_basecounts, gcbias_pdf, gcbias_metrics, gcbias_summary ] 

  qc_merge:
    run: ./roslin-qc/qc-merge.cwl
    in:
      db_files: db_files
      runparams: runparams
      clstats1: clstats1
      clstats2: clstats2
      md_metrics: md_metrics 
      hs_metrics: gather_metrics/hs_metrics
      per_target_coverage: gather_metrics/per_target_coverage
      insert_metrics: gather_metrics/insert_metrics
      doc_basecounts: gather_metrics/doc_basecounts
      qual_metrics: gather_metrics/qual_metrics
    out: [ merged_mdmetrics, merged_hsmetrics, merged_insert_size_histograms, fingerprint_summary, qual_files_r, qual_files_o, cutadapt_summary ]

  compile_directory_for_qcpdf:
    run: ./consolidate-files/consolidate-files.cwl
    in:
      files: [ qc_merge/merged_mdmetrics, qc_merge/merged_hsmetrics, qc_merge/merged_insert_size_histograms, qc_merge/fingerprint_summary, qc_merge/qual_files_r, qc_merge/qual_files_o, qc_merge/cutadapt_summary ]
      output_directory_name:
       valueFrom: ${ return "compiled_metrics_data"; }
    out: [ directory ]

  generate_pdf:
    run: ./roslin-qc/generate-images.cwl
    in:
      runparams: runparams
      db_files: db_files
      data_dir: compile_directory_for_qcpdf/directory
      file_prefix:
        valueFrom: ${ return inputs.runparams.project_prefix; }
    out: [ output, images_directory, project_summary, sample_summary ]

  group_data:
    run: ./consolidate-files/consolidate-files-mixed.cwl
    in:
      project_summary: generate_pdf/project_summary
      sample_summary: generate_pdf/sample_summary
      image_dir: generate_pdf/images_directory
      output_directory_name: 
        valueFrom: ${ return "prepped_files_for_stitching"; }
      files:
        valueFrom: ${ var all = new Array();  all.push(inputs.project_summary); all.push(inputs.sample_summary); return all; }
    out: [ directory ]
 
  stitch_together_pdf:
    run: ./roslin-qc/stitch-pdf.cwl
    in: 
      runparams: runparams
      db_files: db_files
      file_prefix:
        valueFrom: ${ return inputs.runparams.project_prefix; }
      request_file:
        valueFrom: ${ return inputs.db_files.request_file; }
      data_dir: group_data/directory
    out: [ compiled_pdf ]

