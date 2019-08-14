class: CommandLineTool
cwlVersion: v1.0
baseCommand:
  - bwa
  - mem
id: bwa-mem
inputs:
  - id: reads
    type: 'File[]'
    inputBinding:
      position: 3
  - id: reference
    type: File
    inputBinding:
      position: 2
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
      - ^.dict
  - id: sample_id
    type: string
  - id: lane_id
    type: string
  - id: A
    type: int?
    inputBinding:
      position: 0
      prefix: '-A'
  - id: B
    type: int?
    inputBinding:
      position: 0
      prefix: '-B'
  - id: C
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-C'
  - id: E
    type: 'int[]?'
    inputBinding:
      position: 0
      prefix: '-E'
      itemSeparator: ','
  - id: L
    type: 'int[]?'
    inputBinding:
      position: 0
      prefix: '-L'
      itemSeparator: ','
  - id: M
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-M'
  - id: O
    type: 'int[]?'
    inputBinding:
      position: 0
      prefix: '-O'
      itemSeparator: ','
  - id: P
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-P'
  - id: S
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-S'
  - id: T
    type: int?
    inputBinding:
      position: 0
      prefix: '-T'
  - id: U
    type: int?
    inputBinding:
      position: 0
      prefix: '-U'
  - id: a
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-a'
  - id: c
    type: int?
    inputBinding:
      position: 0
      prefix: '-c'
  - id: d
    type: int?
    inputBinding:
      position: 0
      prefix: '-d'
  - id: k
    type: int?
    inputBinding:
      position: 0
      prefix: '-k'
  - id: output
    type: string?
  - id: p
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-p'
  - id: r
    type: float?
    inputBinding:
      position: 0
      prefix: '-r'
  - id: v
    type: int?
    inputBinding:
      position: 0
      prefix: '-v'
  - id: w
    type: int?
    inputBinding:
      position: 0
      prefix: '-w'
  - id: 'y'
    type: int?
    inputBinding:
      position: 0
      prefix: '-y'
  - id: D
    type: float?
    inputBinding:
      position: 0
      prefix: '-D'
  - id: W
    type: int?
    inputBinding:
      position: 0
      prefix: '-W'
  - id: m
    type: int?
    inputBinding:
      position: 0
      prefix: '-m'
  - id: e
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-e'
  - id: x
    type: string?
    inputBinding:
      position: 0
      prefix: '-x'
  - id: H
    type:
      - File?
      - string?
    inputBinding:
      position: 0
      prefix: '-H'
  - id: j
    type: File?
    inputBinding:
      position: 0
      prefix: '-j'
  - id: h
    type: 'int[]?'
    inputBinding:
      position: 0
      prefix: '-h'
      itemSeparator: ','
  - id: V
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-V'
  - id: 'Y'
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-Y'
  - id: I
    type: string?
    inputBinding:
      position: 0
      prefix: '-M'
outputs:
  - id: output_sam
    type: File
    outputBinding:
      glob: '$(inputs.reads[0].basename.replace(''fastq.gz'', ''sam''))'
arguments:
  - position: 0
    prefix: '-R'
    valueFrom: >-
      @RG\\tID:$(inputs.lane_id)\\tSM:$(inputs.sample_id)\\tLB:$(inputs.sample_id)\\tPL:Illumina
  - position: 0
    prefix: '-t'
    valueFrom: $(runtime.cores)
requirements:
  - class: ResourceRequirement
    ramMin: 32000
    coresMin: 4
  - class: DockerRequirement
    dockerPull: 'mskcc/bwa_mem:0.7.12'
  - class: InlineJavascriptRequirement
stdout: '$(inputs.reads[0].basename.replace(''fastq.gz'', ''sam''))'
