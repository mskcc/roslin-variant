cwlVersion: v1.0

class: CommandLineTool
baseCommand: ["head", "-10"]
stdout: output.txt

inputs:
    textfile:
        type: File
        inputBinding:
            position: 1

outputs:
    output:
        type: stdout
