class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
baseCommand:
  - samtools
  - sort
id: samtools-sort
inputs:
  - id: compression_level
    type: int?
    inputBinding:
      position: 0
      prefix: '-l'
    doc: |
      Set compression level, from 0 (uncompressed) to 9 (best)
  - id: input
    type: File
    inputBinding:
      position: 1
    doc: Input bam file.
  - id: memory
    type: string?
    inputBinding:
      position: 0
      prefix: '-m'
    doc: |
      Set maximum memory per thread; suffix K/M/G recognized [768M]
  - id: sort_by_name
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-n'
    doc: >-
      Sort by read names (i.e., the QNAME field) rather than by chromosomal
      coordinates.
  - id: reference
    type: File?
    inputBinding:
      position: 0
      prefix: '--reference'
  - id: output_format
    type: string?
    inputBinding:
      position: 0
      prefix: '-O'
outputs:
  - id: output_file
    type: File
    outputBinding:
      glob: '$(inputs.input.basename.replace(''bam'', ''sorted.bam''))'
doc: >
  Sort alignments by leftmost coordinates, or by read name when -n is used. An
  appropriate @HD-SO sort order header tag will be added or an existing one
  updated if necessary.


  Usage: samtools sort [-l level] [-m maxMem] [-o out.bam] [-O format] [-n] -T
  out.prefix [-@ threads] [in.bam]


  Options:

  -l INT

  Set the desired compression level for the final output file, ranging from 0
  (uncompressed) or 1 (fastest but minimal compression) to 9 (best compression
  but slowest to write), similarly to gzip(1)'s compression level setting.


  If -l is not used, the default compression level will apply.


  -m INT

  Approximately the maximum required memory per thread, specified either in
  bytes or with a K, M, or G suffix. [768 MiB]


  -n

  Sort by read names (i.e., the QNAME field) rather than by chromosomal
  coordinates.


  -o FILE

  Write the final sorted output to FILE, rather than to standard output.


  -O FORMAT

  Write the final output as sam, bam, or cram.


  By default, samtools tries to select a format based on the -o filename
  extension; if output is to standard output or no format can be deduced, -O
  must be used.


  -T PREFIX

  Write temporary files to PREFIX.nnnn.bam. This option is required.


  -@ INT

  Set number of sorting and compression threads. By default, operation is
  single-threaded
arguments:
  - position: 0
    prefix: '-o'
    valueFrom: '$(inputs.input.basename.replace(''bam'', ''sorted.bam''))'
  - position: 0
    prefix: '-@'
    valueFrom: $(runtime.cores)
requirements:
  - class: ResourceRequirement
    ramMin: 32000
    coresMin: 4
  - class: DockerRequirement
    dockerPull: 'quay.io/cancercollaboratory/dockstore-tool-samtools-sort:1.0'
  - class: InlineJavascriptRequirement
'dct:contributor':
  'foaf:mbox': 'mailto:ayang@oicr.on.ca'
  'foaf:name': Andy Yang
'dct:creator':
  '@id': 'http://orcid.org/0000-0001-9102-5681'
  'foaf:mbox': 'mailto:Andrey.Kartashov@cchmc.org'
  'foaf:name': Andrey Kartashov
'dct:description': >-
  Developed at Cincinnati Children���s Hospital Medical Center for the CWL
  consortium http://commonwl.org/ Original URL:
  https://github.com/common-workflow-language/workflows
