cwlVersion: v1.0

class: Workflow

inputs:
    bam: File

steps:
    samtools:
        run: samtools.cwl
        in:
            bam: bam
        out: [output]

    head10:
        run: head-10.cwl
        in:
            textfile: samtools/output
        out: [output]

outputs:
    final:
        type: File
        outputSource: head10/output
