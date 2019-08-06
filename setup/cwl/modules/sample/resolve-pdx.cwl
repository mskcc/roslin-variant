#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

cwlVersion: v1.0

class: Workflow
id: resolve-pdx
requirements:
  StepInputExpressionRequirement: {}
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  r1:
    type: File[]

  r2:
    type: File[]

  sample_id:
    type: string

  lane_id:
    type: string[]

  mouse_reference:
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
      - ^.dict
  human_reference:
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
      - ^.dict
outputs:
  disambiguate_bam:
    type: File
    outputSource: run_disambiguate/disambiguate_a_bam
  summary:
    type: File
    outputSource: run_disambiguate/summary

steps:
  align_to_human:
    run: align_sample.cwl
    in:
      prefix: sample_id
      reference_sequence: human_reference
      r1: r1
      r2: r2
      sample_id:
        valueFrom: ${ return inputs.prefix + "_human"; }
      lane_id: lane_id
    out: [ output_merge_sort_bam ]

  align_to_mouse:
    run: align_sample.cwl
    in:
      prefix: sample_id
      reference_sequence: mouse_reference
      r1: r1
      r2: r2
      sample_id:
        valueFrom: ${ return inputs.prefix + "_mouse"; }
      lane_id: lane_id
    out: [ output_merge_sort_bam ]

  name_sort_human:
    run: ../../tools/samtools.sort/1.3.1/samtools.sort.cwl
    in:
      input: align_to_human/output_merge_sort_bam
      sort_by_name:
        valueFrom: ${ return true; }
    out: [ output_file ]

  name_sort_mouse:
    run: ../../tools/samtools.sort/1.3.1/samtools.sort.cwl
    in:
      input: align_to_mouse/output_merge_sort_bam
      sort_by_name:
        valueFrom: ${ return true; }
    out: [ output_file ]

  run_disambiguate:
    run: ../../tools/disambiguate/1.0.0/disambiguate.cwl
    in:
      prefix: sample_id
      aligner:
        valueFrom: ${ return "bwa"; }
      output_dir:
        valueFrom: ${ return inputs.prefix + "_disambiguated"; }
      species_a_bam: name_sort_human/output_file
      species_b_bam: name_sort_mouse/output_file
    out: [ disambiguate_a_bam, disambiguate_b_bam, summary ]
