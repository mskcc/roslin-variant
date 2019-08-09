#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- file:///juno/work/pi/prototypes/roslin-pipelines/core/2.1.0/schemas/dcterms.rdf
- file:///juno/work/pi/prototypes/roslin-pipelines/core/2.1.0/schemas/foaf.rdf
- file:///juno/work/pi/prototypes/roslin-pipelines/core/2.1.0/schemas/doap.rdf

doap:release:
- class: doap:Version
  doap:name: alignment
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

cwlVersion: v1.0

class: Workflow
id: alignment-pair
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}

inputs:

  pair:
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
          R1: File[]
          R2: File[]
          zR1: File[]
          zR2: File[]
          bam: File[]
          RG_ID: string[]
          adapter: string
          adapter2: string
          bwa_output: string
  genome: string
  intervals: string[]
  tmp_dir: string
  opt_dup_pix_dist: string
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
  covariates: string[]
  abra_scratch: string
  abra_ram_min: int
  gatk_jar_path: string
  bait_intervals: File
  target_intervals: File
  fp_intervals: File
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
  mouse_fasta:
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
      - ^.dict
  conpair_markers_bed: string

outputs:

  bams:
    type: File[]
    secondaryFiles:
      - ^.bai
    outputSource: realignment/outbams
  clstats1:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: sample_alignment/clstats1
  clstats2:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: sample_alignment/clstats2
  md_metrics:
    type: File[]
    outputSource: sample_alignment/md_metrics
  as_metrics:
    type: File[]
    outputSource: sample_alignment/as_metrics
  hs_metrics:
    type: File[]
    outputSource: sample_alignment/hs_metrics
  insert_metrics:
    type: File[]
    outputSource: sample_alignment/insert_metrics
  insert_pdf:
    type: File[]
    outputSource: sample_alignment/insert_pdf
  per_target_coverage:
    type: File[]
    outputSource: sample_alignment/per_target_coverage
  doc_basecounts:
    type: File[]
    outputSource: sample_alignment/doc_basecounts
  gcbias_pdf:
    type: File[]
    outputSource: sample_alignment/gcbias_pdf
  gcbias_metrics:
    type: File[]
    outputSource: sample_alignment/gcbias_metrics
  gcbias_summary:
    type: File[]
    outputSource: sample_alignment/gcbias_summary
  conpair_pileup:
    type: File[]
    outputSource: sample_alignment/conpair_pileup
  covint_list:
    type: File
    outputSource: realignment/covint_list
  bed:
    type: File
    outputSource: realignment/covint_bed
  qual_metrics:
    type: File[]
    outputSource: realignment/qual_metrics
  qual_pdf:
    type: File[]
    outputSource: realignment/qual_pdf

steps:
  sample_alignment:
    run: ../../workflows/sample-workflow.cwl
    in:
      sample: pair
      genome: genome
      tmp_dir: tmp_dir
      opt_dup_pix_dist: opt_dup_pix_dist
      gatk_jar_path: gatk_jar_path
      bait_intervals: bait_intervals
      target_intervals: target_intervals
      fp_intervals: fp_intervals
      ref_fasta: ref_fasta
      mouse_fasta: mouse_fasta
      conpair_markers_bed: conpair_markers_bed
    out: [clstats1,clstats2,bam,md_metrics,as_metrics,hs_metrics,insert_metrics,insert_pdf,per_target_coverage,doc_basecounts,gcbias_pdf,gcbias_metrics,gcbias_summary,conpair_pileup]
    scatter: [sample]
    scatterMethod: dotproduct
  realignment:
    run: realignment.cwl
    in:
      pair: pair
      bams: sample_alignment/bam
      hapmap: hapmap
      dbsnp: dbsnp
      indels_1000g: indels_1000g
      snps_1000g: snps_1000g
      covariates: covariates
      abra_scratch: abra_scratch
      genome: genome
      intervals: intervals
      abra_ram_min: abra_ram_min
      tmp_dir: tmp_dir
    out: [outbams, covint_list, covint_bed, qual_metrics, qual_pdf]
