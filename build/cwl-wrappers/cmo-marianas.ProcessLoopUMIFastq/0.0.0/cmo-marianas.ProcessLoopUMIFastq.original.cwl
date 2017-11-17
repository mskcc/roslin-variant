cwlVersion: cwl:v1.0

class: CommandLineTool

baseCommand: [cmo_process_loop_umi_fastq]

arguments: ["-server", "-Xms8g", "-Xmx8g", "-cp"]

doc: Marianas UMI Clipping module

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

outputs:
  processed_fastq_1:
    type: File
    outputBinding:
      glob: $(inputs.r1_fastq)

  processed_fastq_2:
    type: File
    outputBinding:
      glob: $(inputs.r2_fastq)

#  composite_umi_frequencies:
#    type: File
#    outputBinding:
#      glob: composite-umi-frequencies.txt

  info:
    type: File
    outputBinding:
      glob: info.txt

#   sample_sheet:
#     type: File
#     outputBinding:
#       glob: SampleSheet.csv

  umi_frequencies:
    type: File
    outputBinding:
      glob: umi-frequencies.txt