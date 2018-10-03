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
  doap:name: qc-merge
  doap:revision: 1.0.0
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org

cwlVersion: v1.0

class: Workflow
id: qc-merge
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

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

  per_target_coverage:
    type:
      type: array
      items: File

  insert_metrics:
    type:
      type: array
      items: File

  doc_basecounts:
    type:
      type: array
      items: File

  qual_metrics:
    type: 
      type: array
      items: File

outputs:
  merged_mdmetrics:
    type: File
    outputSource: merge_mdmetrics/output

  merged_hsmetrics:
    type: File
    outputSource: merge_hsmetrics/output

  merged_hstmetrics:
    type: File
    outputSource: merge_hstmetrics/output

  merged_insert_size_histograms:
    type: File
    outputSource: merge_insert_size_histograms/output

  fingerprints_output:
    type: File[]
    outputSource: generate_fingerprint/output

  fingerprint_summary:
    type: File
    outputSource: generate_fingerprint/fp_summary

  qual_files_r:
    type: File
    outputSource: generate_qual_files/rqual_output

  qual_files_o:
    type: File
    outputSource: generate_qual_files/oqual_output

  cutadapt_summary:
    type: File
    outputSource: generate_cutadapt_summary/output

steps:

  merge_mdmetrics:
    in:
      runparams: runparams
      files: md_metrics
      outfile_name: 
        valueFrom: ${ return inputs.runparams.project_prefix + "_markDuplicatesMetrics.txt"; }
    out: [ output ]
    run: ./merge-picard-metrics-markduplicates.cwl

  merge_hsmetrics:
    in:
      runparams: runparams
      files: hs_metrics
      outfile_name: 
        valueFrom: ${ return inputs.runparams.project_prefix + "_HsMetrics.txt"; }
    out: [ output ]
    run: ./merge-picard-metrics-hsmetrics.cwl

  merge_hstmetrics:
    in:
      runparams: runparams
      files: per_target_coverage
      outfile_name:
        valueFrom: ${ return inputs.runparams.project_prefix + "_GcBiasMetrics.txt"; }
    out: [ output ]
    run: ./merge-gcbias-metrics.cwl

  merge_insert_size_histograms:
    in:
      runparams: runparams
      files: insert_metrics
      outfile_name:
        valueFrom: ${ return inputs.runparams.project_prefix + "_InsertSizeMetrics_Histograms.txt"; }
    out: [ output ]
    run: ./merge-insert-size-histograms.cwl

  generate_fingerprint:
    in:
      db_files: db_files
      runparams: runparams
      files: doc_basecounts
      file_prefix:
         valueFrom: ${ return inputs.runparams.project_prefix; }
      fp_genotypes: 
         valueFrom: ${ return inputs.db_files.fp_genotypes; }
      grouping_file:
         valueFrom: ${ return inputs.db_files.grouping_file; }
      pairing_file:
         valueFrom: ${ return inputs.db_files.pairing_file; }
    out: [ output, fp_summary ]
    run: ./generate-fingerprint.cwl

  generate_qual_files:
    in:
      runparams: runparams
      files: qual_metrics
      rqual_output_filename: 
        valueFrom: ${ return inputs.runparams.project_prefix + "_post_recal_MeanQualityByCycle.txt"; }
      oqual_output_filename: 
        valueFrom: ${ return inputs.runparams.project_prefix + "_pre_recal_MeanQualityByCycle.txt"; }
    out: [ rqual_output, oqual_output ]
    run: ./generate-qual-files.cwl

  generate_cutadapt_summary:
    in:
      runparams: runparams
      db_files: db_files
      clstats1: clstats1
      clstats2: clstats2
      output_filename:
        valueFrom: ${ return inputs.runparams.project_prefix + "_CutAdaptStats.txt"; }
      pairing_file:
        valueFrom: ${ return inputs.db_files.pairing_file; }
    out: [ output ]
    run: ./generate-cutadapt-summary.cwl
