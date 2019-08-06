class: CommandLineTool
cwlVersion: v1.0
baseCommand:
  - ngs_disambiguate
id: disambiguate
inputs:
  - id: no_sort
    type: string?
    inputBinding:
      position: 0
      prefix: '--no-sort'
  - id: prefix
    type: string
    inputBinding:
      position: 0
      prefix: '--prefix'
  - id: output_dir
    type: string
    inputBinding:
      position: 0
      prefix: '--output-dir'
  - id: aligner
    type: string
    inputBinding:
      position: 0
      prefix: '--aligner'
    default: 'bwa'
  - id: species_a_bam
    type: File
    inputBinding:
      position: 1
  - id: species_b_bam
    type: File
    inputBinding:
      position: 2

outputs:
  - id: disambiguate_a_bam
    type: File
    outputBinding:
      glob: |
        ${
            return inputs.output_dir.concat('/*.disambiguatedSpeciesA.bam');
        }
  - id: disambiguate_b_bam
    type: File
    outputBinding:
      glob: |
        ${
            return inputs.output_dir.concat('/*.disambiguatedSpeciesB.bam');
        }
  - id: summary
    type: File
    outputBinding:
      glob: |
        ${
            return inputs.output_dir.concat('/*_summary.txt');
        }
requirements:
  - class: ResourceRequirement
    ramMin: 32000
    coresMin: 4
  - class: DockerRequirement
    dockerPull: 'mskcc/disambiguate:1.0.0'
  - class: InlineJavascriptRequirement
