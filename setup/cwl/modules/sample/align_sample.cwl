class: Workflow
cwlVersion: v1.0
id: align_sample
label: align_sample
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
  - id: r1
    type: File[]
  - id: r2
    type: File[]
  - id: sample_id
    type: string
  - id: lane_id
    type: string[]
outputs:
  - id: sample_id_output
    outputSource:
      - bwa_sort/sample_id_output
    type:
      - string
      - type: array
        items: string
  - id: output_md_metrics
    outputSource:
      - gatk_markduplicates/output_md_metrics
    type: File
  - id: output_merge_sort_bam
    outputSource:
      - samtools_merge/output_file
    type: File
  - id: output_md_bam
    outputSource:
      - gatk_markduplicates/output_md_bam
    type: File

steps:
  - id: samtools_merge
    in:
      - id: input_bams
        source:
          - bwa_sort/output_file
    out:
      - id: output_file
    run: ../../tools/samtools.merge/1.9/samtools.merge.cwl
  - id: bwa_sort
    in:
      - id: r1
        source: r1
      - id: r2
        source: r2
      - id: reference_sequence
        source: reference_sequence
      - id: read_pair
        valueFrom: ${ var data = []; data.push(inputs.r1); data.push(inputs.r2); return data; }
      - id: sample_id
        source: sample_id
      - id: lane_id
        source: lane_id
    out:
      - id: output_file
      - id: sample_id_output
      - id: lane_id_output
    run: align_reads.cwl
    label: bwa_sort
    scatter:
      - r1
      - r2
      - lane_id
    scatterMethod: dotproduct
  - id: gatk_markduplicates
    in:
      - id: input
        source: samtools_merge/output_file
    out:
      - id: output_md_bam
      - id: output_md_metrics
    run: ../../tools/gatk.mark_duplicates/4.1.0.0/gatk.mark_duplicates.cwl
    label: GATK MarkDuplicates
requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
