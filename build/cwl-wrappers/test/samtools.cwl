# use sing.sh
cwlVersion: v1.0

class: CommandLineTool
baseCommand: ["sing.sh", "samtools", "1.3.1"]
arguments:
  - id: samtools-command
    valueFrom: "view"

stdout: output.txt

inputs:
  bam:
    type: File
    inputBinding:
      position: 1

outputs:
  output:
    type: stdout
