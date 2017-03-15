# use sing.sh
cwlVersion: v1.0

class: CommandLineTool
baseCommand: ["sing.sh", "samtools", "1.3.1"]
arguments:
  - id: samtools-command
    valueFrom: "view -bh"

inputs:
  sam:
    type: File
    inputBinding:
      position: 1
  output_filename:
    type: string
    inputBinding:
      position: 2
      prefix: -o
    
outputs:
  bam:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
