cwlVersion: cwl:v1.0

class: CommandLineTool

baseCommand: [cmo_marianas]

arguments: ["-server", "-Xms8g", "-Xmx8g", "-cp"]

doc: |
  None

inputs:
  r1_fastq:
    type: File
    inputBinding:
      prefix: --r1_fastq
    secondaryFiles:
    - ${self.location.replace("_R1_", "_R2_")}
    - ${self.location.replace(/(.*)(\/.*$)/, "$1/SampleSheet.csv")}

  umi_length:
    type: string
    inputBinding:
      prefix: --umi_length

  output_project_folder:
    type: string
    inputBinding:
      prefix: --output_project_folder
