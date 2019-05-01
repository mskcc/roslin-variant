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
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Christopher Harris
    foaf:mbox: mailto:harrisc2@mskcc.org
  - class: foaf:Person
    foaf:name: Ronak H. Shah
    foaf:mbox: mailto:shahr2@mskcc.org
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

cwlVersion: v1.0

class: Workflow
id: gather-metrics
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:

  bait_intervals: File
  target_intervals: File
  fp_intervals: File
  ref_fasta: string
  conpair_markers_bed: string
  genome: string
  tmp_dir: string
  gatk_jar_path: string
  bams:
    type: File[]
    secondaryFiles: ^.bai

outputs:

  as_metrics:
    type: File[]
    outputSource: gather_metrics/as_metrics_files
  hs_metrics:
    type: File[]
    outputSource: gather_metrics/hs_metrics_files
  insert_metrics:
    type: File[]
    outputSource: gather_metrics/is_metrics
  insert_pdf:
    type: File[]
    outputSource: gather_metrics/is_hist
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
    outputSource: gather_metrics/gcbias_metrics_files
  gcbias_summary:
    type: File[]
    outputSource: gather_metrics/gcbias_summary
  conpair_pileup:
    type: File[]
    outputSource: gather_metrics/conpair_pileup

steps:

  gather_metrics:
    run: ../sample/gather-metrics-sample.cwl
    in:
      bam: bams
      bait_intervals: bait_intervals
      target_intervals: target_intervals
      fp_intervals: fp_intervals
      ref_fasta: ref_fasta
      conpair_markers_bed: conpair_markers_bed
      genome: genome
      tmp_dir: tmp_dir
      gatk_jar_path: gatk_jar_path
    out: [as_metrics_files, hs_metrics_files, is_metrics, per_target_coverage, qual_metrics, qual_pdf, is_hist, doc_basecounts, gcbias_pdf, gcbias_metrics_files, gcbias_summary, conpair_pileup]
    scatter: [bam]
    scatterMethod: dotproduct