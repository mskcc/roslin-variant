#!/usr/bin/env/cwl-runner

cwlVersion: cwl:v1.0

class: CommandLineTool

baseCommand: [cmo_process_loop_umi_fastq]

arguments: ["-server", "-Xms8g", "-Xmx8g", "-cp"]

doc: Marianas UMI Clipping module

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 4
    coresMin: 1

inputs:
  r1_fastq:
    type: File
    inputBinding:
      prefix: --r1_fastq
    secondaryFiles:
    - ${return self.location.replace("_R1_", "_R2_")}
    - ${return self.location.replace(/(.*)(\/.*$)/, "$1/SampleSheet.csv")}

  umi_length:
    type: string
    inputBinding:
      prefix: --umi_length

  output_project_folder:
    type: string
    inputBinding:
      prefix: --output_project_folder

  outdir:
    type: ['null', string]
    doc: Full Path to the output dir.
    inputBinding:
      prefix: --outDir

outputs:
  processed_fastq_1:
    type: File
    outputBinding:
      glob: ${ return "**/" + inputs.r1_fastq.basename }

  processed_fastq_2:
    type: File
    outputBinding:
      glob: ${ return "**/" + inputs.r1_fastq.basename.replace("_R1_", "_R2_") }

  composite_umi_frequencies:
    type: File
    outputBinding:
      glob: ${ return "**/composite-umi-frequencies.txt" }

  info:
    type: File
    outputBinding:
      glob: ${ return "**/info.txt" }

  sample_sheet:
    type: File
    outputBinding:
      glob: ${ return "**/SampleSheet.csv" }

  umi_frequencies:
    type: File
    outputBinding:
      glob: ${ return "**/umi-frequencies.txt" }
