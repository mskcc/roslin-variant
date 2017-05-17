#!/usr/bin/env cwl-runner

class: ExpressionTool
requirements:
  - class: InlineJavascriptRequirement
cwlVersion: v1.0

inputs:
  bams:
    type:
      type: array
      items:
        type: array
        items: File
    secondaryFiles: ['^.bai']
outputs:
  bams:
    type:
      type: array
      items: File
    secondaryFiles: ['^.bai']


expression: ${var samples = []; for (var i = 0; i < inputs.bams.length; i++) { for (var j =0; j < inputs.bams[i].length; j++) { samples.push(inputs.bams[i][j]) } } return {"bams":samples};}
