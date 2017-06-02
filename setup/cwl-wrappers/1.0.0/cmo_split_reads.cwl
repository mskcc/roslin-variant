#!/usr/bin/env cwl-runner
cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand: [cmo_split_reads]

requirements:
  ResourceRequirement:
    ramMin: 8 
    coresMin: 1


inputs:
  fastq1:
    type: File
    inputBinding:
        prefix: --fastq1
  fastq2:
    type: File
    inputBinding:
        prefix: --fastq2
    doc: picard interval list

outputs:
  chunks1:
    type:
      type: array
      items: File
    outputBinding:
      glob: "*R1*chunk*fastq.gz"
  chunks2: 
    type: 
      type: array
      items: File
    outputBinding:
      glob: "*R2*chunk*fastq.gz"

