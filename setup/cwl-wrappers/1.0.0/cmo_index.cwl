#!/usr/bin/env cwl-runner
cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand: [cmo_index]

requirements:
  ResourceRequirement:
    ramMin: 2
    coresMin: 1


inputs:
  tumor:
    type: File
    inputBinding:
        prefix: --tumor
  normal:
    type: File
    inputBinding:
        prefix: --normal
    doc: picard interval list

outputs:
  tumor_bam: 
    type: File
    outputBinding:
      glob: $(inputs.tumor.basename)
    secondaryFiles: ["^.bai", ".bai"]
  normal_bam: 
    type: File
    outputBinding:
      glob: $(inputs.normal.basename)
    secondaryFiles: ["^.bai", ".bai"]
