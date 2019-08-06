class: CommandLineTool
cwlVersion: v1.0

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

baseCommand:
  - samtools
  - view
id: samtools-view
inputs:
  - id: bedoverlap
    type: File?
    inputBinding:
      position: 1
      prefix: '-L'
    doc: |
      only include reads overlapping this BED FILE [null]
  - id: cigar
    type: int?
    inputBinding:
      position: 1
      prefix: '-m'
    doc: |
      only include reads with number of CIGAR operations
      consuming query sequence >= INT [0]
  - default: false
    id: collapsecigar
    type: boolean
    inputBinding:
      position: 1
      prefix: '-B'
    doc: |
      collapse the backward CIGAR operation
  - default: false
    id: count
    type: boolean
    inputBinding:
      position: 1
      prefix: '-c'
    doc: |
      print only the count of matching records
  - default: false
    id: fastcompression
    type: boolean
    inputBinding:
      position: 1
      prefix: '-1'
    doc: |
      use fast BAM compression (implies -b)
  - id: input
    type: File
    inputBinding:
      position: 4
    doc: |
      Input bam file.
  - default: false
    id: isbam
    type: boolean
    inputBinding:
      position: 2
      prefix: '-b'
    doc: |
      output in BAM format
  - default: false
    id: iscram
    type: boolean
    inputBinding:
      position: 2
      prefix: '-C'
    doc: |
      output in CRAM format
  - id: randomseed
    type: float?
    inputBinding:
      position: 1
      prefix: '-s'
    doc: |
      integer part sets seed of random number generator [0];
      rest sets fraction of templates to subsample [no subsampling]
  - id: readsingroup
    type: string?
    inputBinding:
      position: 1
      prefix: '-r'
    doc: |
      only include reads in read group STR [null]
  - id: readsingroupfile
    type: File?
    inputBinding:
      position: 1
      prefix: '-R'
    doc: |
      only include reads with read group listed in FILE [null]
  - id: readsinlibrary
    type: string?
    inputBinding:
      position: 1
      prefix: '-l'
    doc: |
      only include reads in library STR [null]
  - id: readsquality
    type: int?
    inputBinding:
      position: 1
      prefix: '-q'
    doc: |
      only include reads with mapping quality >= INT [0]
  - id: readswithbits
    type: int?
    inputBinding:
      position: 1
      prefix: '-f'
    doc: |
      only include reads with all bits set in INT set in FLAG [0]
  - id: readswithoutbits
    type: int?
    inputBinding:
      position: 1
      prefix: '-F'
    doc: |
      only include reads with none of the bits set in INT set in FLAG [0]
  - id: readtagtostrip
    type: 'string[]?'
    inputBinding:
      position: 0
      prefix: '-x'
    doc: |
      read tag to strip (repeatable) [null]
  - id: referencefasta
    type: File?
    inputBinding:
      position: 1
      prefix: '-T'
    doc: |
      reference sequence FASTA FILE [null]
  - id: region
    type: string?
    inputBinding:
      position: 5
    doc: |
      [region ...]
  - default: false
    id: samheader
    type: boolean
    inputBinding:
      position: 1
      prefix: '-h'
    doc: |
      include header in SAM output
  - id: threads
    type: int?
    inputBinding:
      position: 1
      prefix: '-@'
    doc: |
      number of BAM compression threads [0]
  - default: false
    id: uncompressed
    type: boolean
    inputBinding:
      position: 1
      prefix: '-u'
    doc: |
      uncompressed BAM output (implies -b)
  - id: samheaderonly
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-H'
  - id: outputreadsnotselectedbyfilters
    type: File?
    inputBinding:
      position: 0
      prefix: '-U'
  - id: listingreferencenamesandlengths
    type: File?
    inputBinding:
      position: 0
      prefix: '-t'
  - id: readtagtostri
    type: File?
    inputBinding:
      position: 0
      prefix: '-x'
  - id: output_format
    type: string?
    inputBinding:
      position: 0
      prefix: '-O'
outputs:
  - id: output_bam
    type: File
    outputBinding:
      glob: '$(inputs.input.basename.replace(''sam'', ''bam''))'
doc: >
  Prints alignments in the specified input alignment file.


  With no options or regions specified, prints all alignments in the specified
  input alignment file (in SAM, BAM, or CRAM format) to standard output in SAM
  format (with no header).


  You may specify one or more space-separated region specifications after the
  input filename to restrict output to only those alignments which overlap the
  specified region(s). Use of region specifications requires a coordinate-sorted
  and indexed input file (in BAM or CRAM format).


  The -b, -C, -1, -u, -h, -H, and -c options change the output format from the
  default of headerless SAM, and the -o and -U options set the output file
  name(s).


  The -t and -T options provide additional reference data. One of these two
  options is required when SAM input does not contain @SQ headers, and the -T
  option is required whenever writing CRAM output.


  The -L, -r, -R, -q, -l, -m, -f, and -F options filter the alignments that will
  be included in the output to only those alignments that match certain
  criteria.


  The -x, -B, and -s options modify the data which is contained in each
  alignment.


  Finally, the -@ option can be used to allocate additional threads to be used
  for compression, and the -? option requests a long help message.


  Usage: samtools view [options] in.bam|in.sam|in.cram [region...]


  Regions can be specified as: RNAME[:STARTPOS[-ENDPOS]] and all position
  coordinates are 1-based.


  Important note: when multiple regions are given, some alignments may be output
  multiple times if they overlap more than one of the specified regions.


  Examples of region specifications:


  `chr1'

  Output all alignments mapped to the reference sequence named `chr1' (i.e. @SQ
  SN:chr1) .


  `chr2:1000000'

  The region on chr2 beginning at base position 1,000,000 and ending at the end
  of the chromosome.


  `chr3:1000-2000'

  The 1001bp region on chr3 beginning at base position 1,000 and ending at base
  position 2,000 (including both end positions).


  OPTIONS:


  -b

  Output in the BAM format.


  -C

  Output in the CRAM format (requires -T).


  -1

  Enable fast BAM compression (implies -b).


  -u

  Output uncompressed BAM. This option saves time spent on
  compression/decompression and is thus preferred when the output is piped to
  another samtools command.


  -h

  Include the header in the output.


  -H

  Output the header only.


  -c

  Instead of printing the alignments, only count them and print the total
  number. All filter options, such as -f, -F, and -q, are taken into account.


  -?

  Output long help and exit immediately.


  -o FILE

  Output to FILE [stdout].


  -U FILE

  Write alignments that are not selected by the various filter options to FILE.
  When this option is used, all alignments (or all alignments intersecting the
  regions specified) are written to either the output file or this file, but
  never both.


  -t FILE

  A tab-delimited FILE. Each line must contain the reference name in the first
  column and the length of the reference in the second column, with one line for
  each distinct reference. Any additional fields beyond the second column are
  ignored. This file also defines the order of the reference sequences in
  sorting. If you run: `samtools faidx <ref.fa>', the resulting index file
  <ref.fa>.fai can be used as this FILE.


  -T FILE

  A FASTA format reference FILE, optionally compressed by bgzip and ideally
  indexed by samtools faidx. If an index is not present, one will be generated
  for you.


  -L FILE

  Only output alignments overlapping the input BED FILE [null].


  -r STR

  Only output alignments in read group STR [null].


  -R FILE

  Output alignments in read groups listed in FILE [null].


  -q INT

  Skip alignments with MAPQ smaller than INT [0].


  -l STR

  Only output alignments in library STR [null].


  -m INT

  Only output alignments with number of CIGAR bases consuming query sequence ���
  INT [0]


  -f INT

  Only output alignments with all bits set in INT present in the FLAG field. INT
  can be specified in hex by beginning with `0x' (i.e. /^0x[0-9A-F]+/) or in
  octal by beginning with `0' (i.e. /^0[0-7]+/) [0].


  -F INT

  Do not output alignments with any bits set in INT present in the FLAG field.
  INT can be specified in hex by beginning with `0x' (i.e. /^0x[0-9A-F]+/) or in
  octal by beginning with `0' (i.e. /^0[0-7]+/) [0].


  -x STR

  Read tag to exclude from output (repeatable) [null]


  -B

  Collapse the backward CIGAR operation.


  -s FLOAT

  Integer part is used to seed the random number generator [0]. Part after the
  decimal point sets the fraction of templates/pairs to subsample [no
  subsampling].


  -@ INT

  Number of BAM compression threads to use in addition to main thread [0].


  -S

  Ignored for compatibility with previous samtools versions. Previously this
  option was required if input was in SAM format, but now the correct format is
  automatically detected by examining the first few characters of input.
arguments:
  - position: 0
    prefix: '-o'
    valueFrom: '$(inputs.input.basename.replace(''sam'', ''bam''))'
  - position: 0
    prefix: '--threads'
    valueFrom: $(runtime.cores)
requirements:
  - class: ResourceRequirement
    ramMin: 32000
    coresMin: 4
  - class: DockerRequirement
    dockerPull: 'quay.io/cancercollaboratory/dockstore-tool-samtools-view:1.0'
  - class: InlineJavascriptRequirement
