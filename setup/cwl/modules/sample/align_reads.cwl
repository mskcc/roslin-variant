class: Workflow
cwlVersion: v1.0
id: bwa_sort
label: bwa_sort
$namespaces:
  foaf: 'http://xmlns.com/foaf/0.1/'
inputs:
  - id: reference_sequence
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
      - ^.dict
  - id: read_pair
    type: File[]
  - id: sample_id
    type: string
  - id: lane_id
    type: string
outputs:
  - id: output_file
    outputSource:
      - samtools_sort/output_file
    type: File
  - id: sample_id_output
    outputSource:
      - sample_id
    type: string
  - id: lane_id_output
    outputSource:
      - lane_id
    type: string
steps:
  - id: bwa_mem
    in:
      - id: reads
        source:
          - read_pair
      - id: reference
        source: reference_sequence
      - id: sample_id
        source: sample_id
      - id: lane_id
        source: lane_id
    out:
      - id: output_sam
    run: ../../tools/bwa-mem/0.7.12/bwa-mem.cwl
  - id: samtools_sort
    in:
      - id: input
        source: sam_to_bam/output_bam
    out:
      - id: output_file
    run: ../../tools/samtools.sort/1.3.1/samtools.sort.cwl
  - id: sam_to_bam
    in:
      - id: input
        source: bwa_mem/output_sam
    out:
      - id: output_bam
    run: ../../tools/samtools.view/1.3.1/samtools.view.cwl
requirements: []
