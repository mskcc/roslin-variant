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

