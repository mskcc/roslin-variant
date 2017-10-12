cwlVersion: v1.0

class: CommandLineTool
baseCommand: ["env"]
stdout: env.txt

inputs:
    message: string

outputs:
    output:
        type: stdout
