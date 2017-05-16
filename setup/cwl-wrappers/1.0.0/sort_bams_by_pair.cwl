#!/usr/bin/env cwl-runner

class: ExpressionTool
requirements:
  - class: InlineJavascriptRequirement
cwlVersion: v1.0

inputs:
  bams:
    type: 
      type: array
      items: File
  pairs:
    type:
      type: array
      items: 
        type: array
        items: string
outputs:
  tumor_bams:
    type:
      type: array
      items: File
  normal_bams:
    type:
      type: array
      items: File
  tumor_sample_ids:
    type:
      type: array
      items: string
  normal_sample_ids:
    type:
      type: array
      items: string

expression: "${var samples = {}; for (var i = 0; i < inputs.bams.length; i++) { var matches = inputs.bams[i].basename.match(/([^.]*)./); samples[matches[1]]=inputs.bams[i]; } var tumor_bams = [], tumor_sample_ids=[]; var normal_bams = [], normal_sample_ids=[]; for (var i=0; i < inputs.pairs.length; i++) { tumor_bams.push(samples[inputs.pairs[i][0]]); normal_bams.push(samples[inputs.pairs[i][1]]); tumor_sample_ids.push(inputs.pairs[i][0]); normal_sample_ids.push(inputs.pairs[i][1]); } return {'tumor_bams': tumor_bams, 'normal_bams': normal_bams, 'tumor_sample_ids': tumor_sample_ids, 'normal_sample_ids': normal_sample_ids};}"
