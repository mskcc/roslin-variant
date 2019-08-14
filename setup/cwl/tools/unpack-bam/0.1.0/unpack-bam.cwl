class: CommandLineTool
cwlVersion: v1.0
id: unpack-bam
baseCommand:
  - perl
  - /opt/unpack_bam.pl
inputs:
  - id: input_bam
    type: File
    inputBinding:
      position: 0
      prefix: '--input-bam'
  - id: sample_id
    type: string
    inputBinding:
      position: 0
      prefix: '--sample-id'
  - id: picard_jar
    type: string
    default: "/opt/common/CentOS_6-dev/picard/v2.13/picard.jar"
    inputBinding:
      position: 0
      prefix: '--picard-jar'
  - id: output_dir
    type: string
    default: "fastqs"
    inputBinding:
      position: 0
      prefix: '--output-dir'
  - id: tmp_dir
    type: string
    default: "/tmp"
    inputBinding:
      position: 0
      prefix: '--tmp-dir'
outputs:
  - id: rg_output
    type: Directory
    outputBinding:
      glob: |
        ${
          return inputs.output_dir;
         }
label: unpack-bam
requirements:
  - class: DockerRequirement
    dockerPull: 'mskcc/unpack_bam:0.1.0'
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 16000
    coresMin: 2
