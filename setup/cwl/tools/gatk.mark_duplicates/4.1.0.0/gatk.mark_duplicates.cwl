class: CommandLineTool
cwlVersion: v1.0
id: gatk_markduplicates
baseCommand:
  - gatk
  - MarkDuplicates
inputs:
  - id: input
    type: File
    inputBinding:
      position: 0
      prefix: '--INPUT'
    doc: Input BAM file
  - id: arguments_file
    type: File?
    inputBinding:
      position: 0
      prefix: '--arguments_file'
  - id: assume_sort_order
    type: string?
    inputBinding:
      position: 0
      prefix: '--ASSUME_SORT_ORDER'
  - id: assume_sorted
    type: boolean?
    inputBinding:
      position: 0
      prefix: '--ASSUME_SORTED'
  - id: barcode_tag
    type: string?
    inputBinding:
      position: 0
      prefix: '--BARCODE_TAG'
  - id: clear_dt
    type: boolean?
    inputBinding:
      position: 0
      prefix: '--CLEAR_DT'
  - id: comment
    type: string?
    inputBinding:
      position: 0
      prefix: '--COMMENT'
  - id: duplex_umi
    type: boolean?
    inputBinding:
      position: 0
      prefix: '--DUPLEX_UMI'
  - id: duplicate_scoring_strategy
    type: string?
    inputBinding:
      position: 0
      prefix: '--DUPLICATE_SCORING_STRATEGY'
  - id: max_file_hendles_for_read_ends_map
    type: int?
    inputBinding:
      position: 0
      prefix: '--MAX_FILE_HANDLES_FOR_READ_ENDS_MAP'
  - id: max_optical_duplicate_set_size
    type: float?
    inputBinding:
      position: 0
      prefix: '--MAX_OPTICAL_DUPLICATE_SET_SIZE'
  - id: max_sequences_for_disk_read_ends_map
    type: int?
    inputBinding:
      position: 0
      prefix: '--MAX_SEQUENCES_FOR_DISK_READ_ENDS_MAP'
  - id: molecular_identifier_tag
    type: string?
    inputBinding:
      position: 0
      prefix: '--MOLECULAR_IDENTIFIER_TAG'
  - id: optical_duplicate_pixel_distance
    type: int?
    inputBinding:
      position: 0
      prefix: '--OPTICAL_DUPLICATE_PIXEL_DISTANCE'
  - id: program_group_command_line
    type: string?
    inputBinding:
      position: 0
      prefix: '--PROGRAM_GROUP_COMMAND_LINE'
  - id: program_group_name
    type: string?
    inputBinding:
      position: 0
      prefix: '--PROGRAM_GROUP_NAME'
  - id: program_group_version
    type: string?
    inputBinding:
      position: 0
      prefix: '--PROGRAM_GROUP_VERSION'
  - id: program_record_id
    type: string?
    inputBinding:
      position: 0
      prefix: '--PROGRAM_RECORD_ID'
  - id: read_name_regex
    type: string?
    inputBinding:
      position: 0
      prefix: '--READ_NAME_REGEX'
  - id: read_one_barcode_tag
    type: string?
    inputBinding:
      position: 0
      prefix: '--READ_ONE_BARCODE_TAG'
  - id: read_two_barcode_tag
    type: string?
    inputBinding:
      position: 0
      prefix: '--READ_TWO_BARCODE_TAG'
  - id: remove_duplicates
    type: boolean?
    inputBinding:
      position: 0
      prefix: '--REMOVE_DUPLICATES'
  - id: remove_sequencing_duplicates
    type: boolean?
    inputBinding:
      position: 0
      prefix: '--REMOVE_SEQUENCING_DUPLICATES'
  - id: sorting_collection_size_ratio
    type: float?
    inputBinding:
      position: 0
      prefix: '--SORTING_COLLECTION_SIZE_RATIO'
  - id: tag_duplicate_set_members
    type: boolean?
    inputBinding:
      position: 0
      prefix: '--TAG_DUPLICATE_SET_MEMBERS'
  - id: tagging_policy
    type: string?
    inputBinding:
      position: 0
      prefix: '--TAGGING_POLICY'
outputs:
  - id: output_md_bam
    doc: Output marked duplicate bam
    type: File
    outputBinding:
      glob: '$(inputs.input.basename.replace(''md.bam'', ''bam''))'
    secondaryFiles:
      - ^.bai
  - id: output_md_metrics
    doc: Output marked duplicate metrics
    type: File
    outputBinding:
      glob: '$(inputs.input.basename.replace(''bam'', ''md.metrics''))'
label: GATK MarkDuplicates
arguments:
  - position: 0
    prefix: '--OUTPUT'
    valueFrom: '$(inputs.input.basename.replace(''md.bam'', ''bam''))'
  - position: 0
    prefix: '--METRICS_FILE'
    valueFrom: '$(inputs.input.basename.replace(''bam'', ''md.metrics''))'
  - position: 0
    prefix: '--TMP_DIR'
    valueFrom: .
  - position: 0
    prefix: '--ASSUME_SORT_ORDER'
    valueFrom: coordinate
  - position: 0
  - position: 0
    prefix: '--CREATE_INDEX'
    valueFrom: 'true'
  - position: 0
    prefix: '--MAX_RECORDS_IN_RAM'
    valueFrom: '50000'
  - position: 0
    prefix: '--java-options'
    valueFrom: '-Xms$(parseInt(runtime.ram)/2000)g -Xmx$(parseInt(runtime.ram)/1000)g'
requirements:
  - class: ResourceRequirement
    ramMin: 32000
    coresMin: 4
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.1.0.0'
  - class: InlineJavascriptRequirement
