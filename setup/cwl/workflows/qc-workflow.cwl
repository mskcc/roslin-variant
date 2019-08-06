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
  doap:name: qc-workflow
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
id: qc-workflow
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
        fp_genotypes: File
        grouping_file: File
        pairing_file: File
        request_file: File
        hotspot_list_maf: File
        conpair_markers: string
        bait_intervals: File
        target_intervals: File
        fp_intervals: File
        conpair_markers_bed: string
  runparams:
    type:
      type: record
      fields:
        project_prefix: string
        genome: string
        scripts_bin: string
        tmp_dir: string
        gatk_jar_path: string
  ref_fasta:
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
      - ^.dict
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
  directories:
    type:
      type: array
      items: Directory
    default: []
  files:
    type:
      type: array
      items: File
    default: []

outputs:

  # qc
  qc_pdf:
    type: File
    outputSource: generate_qc/qc_pdf
  consolidated_results:
    type: Directory
    outputSource: generate_qc/consolidated_results

steps:

  gather_metrics:
    run: ../modules/sample/gather-metrics-sample.cwl
    in:
      db_files: db_files
      runparams: runparams
      bait_intervals:
        valueFrom: ${ return inputs.db_files.bait_intervals }
      target_intervals:
        valueFrom: ${ return inputs.db_files.target_intervals }
      fp_intervals:
        valueFrom: ${ return inputs.db_files.fp_intervals }
      ref_fasta: ref_fasta
      conpair_markers_bed:
        valueFrom: ${ return inputs.db_files.conpair_markers_bed }
      genome:
        valueFrom: ${ return inputs.runparams.genome }
      tmp_dir:
        valueFrom: ${ return inputs.runparams.tmp_dir }
      gatk_jar_path:
        valueFrom: ${ return inputs.runparams.gatk_jar_path }
      bams: bams
    out: [ as_metrics, hs_metrics, insert_metrics, insert_pdf, per_target_coverage, qual_metrics, qual_pdf, doc_basecounts, gcbias_pdf, gcbias_metrics, gcbias_summary, conpair_pileups ]
    scatter: [bams]
    scatterMethod: dotproduct

  generate_qc:
    run: ../modules/project/generate-qc.cwl
    in:
      db_files: db_files
      runparams: runparams
      bams: bams
      clstats1: clstats1
      clstats2: clstats2
      md_metrics: md_metrics
      hs_metrics: gather_metrics/hs_metrics
      insert_metrics: gather_metrics/insert_metrics
      per_target_coverage: gather_metrics/per_target_coverage
      qual_metrics: gather_metrics/qual_metrics
      doc_basecounts: gather_metrics/doc_basecounts
      conpair_pileups: gather_metrics/conpair_pileups
      files: files
      directories: directories
    out: [consolidated_results,qc_pdf]
