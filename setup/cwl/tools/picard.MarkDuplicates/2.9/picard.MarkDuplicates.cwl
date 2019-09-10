#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#

doap:release:
- class: doap:Version
  doap:name: picard.MarkDuplicates
  doap:revision: 2.9
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_picard -b cmo_picard --version 2.13 --java-version jdk1.8.0_25 --cmd MarkDuplicates --generate_cwl_tool
# Help: $ cmo_picard  --help_arg2cwl

cwlVersion: v1.0

class: CommandLineTool
id: picard-MarkDuplicates

arguments:
- valueFrom: "--jar MarkDuplicates"
  position: 1

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 32000
    coresMin: 1
  DockerRequirement:
    dockerPull: mskcc/roslin-variant-picard:2.9


doc: |
  None

inputs:

  java_args:
    type: string
    default: "-Xms256m -Xmx30g -XX:-UseGCOverheadLimit"
    inputBinding:
      position: 0

  java_temp:
    type: string
    inputBinding:
      prefix: -Djava.io.tmpdir=
      position: 0
      separate: false

  TMP_DIR:
    type: string
    inputBinding:
      prefix: TMP_DIR=
      position: 2
      separate: false

  I:
    type:
    - type: array
      items: File
      inputBinding:
        prefix: I=
        position: 2
        separate: false

  MAX_SEQS:
    type: ['null', string]
    doc: This option is obsolete. ReadEnds will always be spilled to disk. Default
      value - 50000. This option can be set to 'null' to clear the default value.
    inputBinding:
      prefix: MAX_SEQUENCES_FOR_DISK_READ_ENDS_MAP=
      position: 2
      separate: false

  MAX_FILE_HANDLES:
    type: ['null', string]
    doc: Maximum number of file handles to keep open when spilling read ends to disk.
      Set this number a little lower than the per-process maximum number of file that
      may be open. This number can be found by executing the 'ulimit -n' command on
      a Unix system. Default value - 8000. This option can be set to 'null' to clear
      the default value.
    inputBinding:
      prefix: MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=
      position: 2
      separate: false

  SORTING_COLLECTION_SIZE_RATIO:
    type: ['null', string]
    doc: This number, plus the maximum RAM available to the JVM, determine the memory
      footprint used by some of the sorting collections. If you are running out of
      memory, try reducing this number. Default value - 0.25. This option can be set
      to 'null' to clear the default value.
    inputBinding:
      prefix: SORTING_COLLECTION_SIZE_RATIO=
      position: 2
      separate: false

  BARCODE_TAG:
    type: ['null', string]
    doc: Barcode SAM tag (ex. BC for 10X Genomics) Default value - null.
    inputBinding:
      prefix: BARCODE_TAG=
      position: 2
      separate: false

  READ_ONE_BARCODE_TAG:
    type: ['null', string]
    doc: Read one barcode SAM tag (ex. BX for 10X Genomics) Default value - null.
    inputBinding:
      prefix: READ_ONE_BARCODE_TAG=
      position: 2
      separate: false

  READ_TWO_BARCODE_TAG:
    type: ['null', string]
    doc: Read two barcode SAM tag (ex. BX for 10X Genomics) Default value - null.
    inputBinding:
      prefix: READ_TWO_BARCODE_TAG=
      position: 2
      separate: false

  TAG_DUPLICATE_SET_MEMBERS:
    type: ['null', string]
    doc: If a read appears in a duplicate set, add two tags. The first tag, DUPLICATE_SET_SIZE_TAG
      (DS), indicates the size of the duplicate set. The smallest possible DS value
      is 2 which occurs when two reads map to the same portion of the reference only
      one of which is marked as duplicate. The second tag, DUPLICATE_SET_INDEX_TAG
      (DI), represents a unique identifier for the duplicate set to which the record
      belongs. This identifier is the index-in-file of the representative read that
      was selected out of the duplicate set. Default value - false. This option can
      be set to 'null' to clear the default value. Possible values - {true, false}
    inputBinding:
      prefix: TAG_DUPLICATE_SET_MEMBERS=
      position: 2
      separate: false

  REMOVE_SEQUENCING_DUPLICATES:
    type: ['null', string]
    doc: If true remove 'optical' duplicates and other duplicates that appear to have
      arisen from the sequencing process instead of the library preparation process,
      even if REMOVE_DUPLICATES is false. If REMOVE_DUPLICATES is true, all duplicates
      are removed and this option is ignored. Default value - false. This option can
      be set to 'null' to clear the default value. Possible values - {true, false}
    inputBinding:
      prefix: REMOVE_SEQUENCING_DUPLICATES=
      position: 2
      separate: false

  TAGGING_POLICY:
    type: ['null', string]
    doc: Determines how duplicate types are recorded in the DT optional attribute.
      Default value - DontTag. This option can be set to 'null' to clear the default
      value. Possible values - {DontTag, OpticalOnly, All}
    inputBinding:
      prefix: TAGGING_POLICY=
      position: 2
      separate: false

  CLEAR_DT:
    type: ['null', string]
    doc: Clear DT tag from input SAM records. Should be set to false if input SAM
      doesn't have this tag. Default true Default value - true. This option can be
      set to 'null' to clear the default value. Possible values - {true, false}
    inputBinding:
      prefix: CLEAR_DT=
      position: 2
      separate: false

  O:
    type: string
    doc: The output file to write marked records to Required.
    inputBinding:
      prefix: O=
      position: 2
      separate: false

  M:
    type: string
    doc: File to write duplication metrics to Required.
    inputBinding:
      prefix: METRICS_FILE=
      position: 2
      separate: false

  REMOVE_DUPLICATES:
    type: ['null', boolean]
    doc: If true do not write duplicates to the output file instead of writing them
      with appropriate flags set. Default value - false. This option can be set to
      'null' to clear the default value. Possible values - {true, false}
    inputBinding:
      prefix: REMOVE_DUPLICATES=True
      position: 2

  ASO:
    type: ['null', string]
    doc: If not null, assume that the input file has this order even if the header
      says otherwise. Default value - null. Possible values - {unsorted, queryname,
      coordinate, duplicate, unknown} Cannot be used in conjuction with option(s)
      ASSUME_SORTED (AS)
    inputBinding:
      prefix: ASSUME_SORT_ORDER=
      position: 2
      separate: false

  DS:
    type: ['null', string]
    doc: The scoring strategy for choosing the non-duplicate among candidates. Default
      value - SUM_OF_BASE_QUALITIES. This option can be set to 'null' to clear the
      default value. Possible values - {SUM_OF_BASE_QUALITIES, TOTAL_MAPPED_REFERENCE_LENGTH,
      RANDOM}
    inputBinding:
      prefix: DUPLICATE_SCORING_STRATEGY=
      position: 2
      separate: false

  PG:
    type: ['null', string]
    doc: The program record ID for the @PG record(s) created by this program. Set
      to null to disable PG record creation. This string may have a suffix appended
      to avoid collision with other program record IDs. Default value - MarkDuplicates.
      This option can be set to 'null' to clear the default value.
    inputBinding:
      prefix: PROGRAM_RECORD_ID=
      position: 2
      separate: false

  PG_VERSION:
    type: ['null', string]
    doc: Value of VN tag of PG record to be created. If not specified, the version
      will be detected automatically. Default value - null.
    inputBinding:
      prefix: PROGRAM_GROUP_VERSION=
      position: 2
      separate: false

  PG_COMMAND:
    type: ['null', string]
    doc: Value of CL tag of PG record to be created. If not supplied the command line
      will be detected automatically. Default value - null.
    inputBinding:
      prefix: PROGRAM_GROUP_COMMAND_LINE=
      position: 2
      separate: false

  PG_NAME:
    type: ['null', string]
    doc: Value of PN tag of PG record to be created. Default value - MarkDuplicates.
      This option can be set to 'null' to clear the default value.
    inputBinding:
      prefix: PROGRAM_GROUP_NAME=
      position: 2
      separate: false

  CO:
    type: ['null', string]
    doc: Comment(s) to include in the output file's header. Default value - null.
      This option may be specified 0 or more times.
    inputBinding:
      prefix: COMMENT=
      position: 2
      separate: false

  READ_NAME_REGEX:
    type: ['null', string]
    doc: Regular expression that can be used to parse read names in the incoming SAM
      file. Read names are parsed to extract three variables - tile/region, x coordinate
      and y coordinate. These values are used to estimate the rate of optical duplication
      in order to give a more accurate estimated library size. Set this option to
      null to disable optical duplicate detection, e.g. for RNA-seq or other data
      where duplicate sets are extremely large and estimating library complexity is
      not an aim. Note that without optical duplicate counts, library size estimation
      will be inaccurate. The regular expression should contain three capture groups
      for the three variables, in order. It must match the entire read name. Note
      that if the default regex is specified, a regex match is not actually done,
      but instead the read name is split on colon character. For 5 element names,
      the 3rd, 4th and 5th elements are assumed to be tile, x and y values. For 7
      element names (CASAVA 1.8), the 5th, 6th, and 7th elements are assumed to be
      tile, x and y values. Default value - <optimized capture of last three ' -'
      separated fields as numeric values>. This option can be set to 'null' to clear
      the default value.
    inputBinding:
      prefix: READ_NAME_REGEX=
      position: 2
      separate: false

  OPTICAL_DUPLICATE_PIXEL_DISTANCE:
    type: ['null', string]
    doc: The maximum offset between two duplicate clusters in order to consider them
      optical duplicates. The default is appropriate for unpatterned versions of the
      Illumina platform. For the patterned flowcell models, 2500 is moreappropriate.
      For other platforms and models, users should experiment to find what works best.
      Default value - 100. This option can be set to 'null' to clear the default value.
    inputBinding:
      prefix: OPTICAL_DUPLICATE_PIXEL_DISTANCE=
      position: 2
      separate: false

  MAX_OPTICAL_DUPLICATE_SET_SIZE:
    type: ['null', string]
    doc: This number is the maximum size of a set of duplicate reads for which we
      will attempt to determine which are optical duplicates. Please be aware that
      if you raise this value too high and do encounter a very large set of duplicate
      reads, it will severely affect the runtime of this tool. To completely disable
      this check, set the value to -1. Default value - 300000. This option can be
      set to 'null' to clear the default value.
    inputBinding:
      prefix: MAX_OPTICAL_DUPLICATE_SET_SIZE=
      position: 2
      separate: false

  AS:
    type: ['null', boolean]
    doc: If true (default), then the sort order in the header file will be ignored.
      Default value - true. This option can be set to 'null' to clear the default
      value. Possible values - {true, false}
    inputBinding:
      prefix: ASSUME_SORTED=True
      separate: false
      position: 2

  STOP_AFTER:
    type: ['null', string]
    doc: Stop after processing N reads, mainly for debugging. Default value - 0. This
      option can be set to 'null' to clear the default value.
    inputBinding:
      prefix: STOP_AFTER=
      position: 2
      separate: false

  QUIET:
    type: ['null', boolean]
    default: false
    inputBinding:
      prefix: QUIET=True
      position: 2

  CREATE_MD5_FILE:
    type: ['null', boolean]
    default: false
    inputBinding:
      prefix: CREATE_MD5_FILE=True
      position: 2

  CREATE_INDEX:
    type: ['null', boolean]
    default: true
    inputBinding:
      prefix: CREATE_INDEX=True
      position: 2

  VERBOSITY:
    type: ['null', string]
    inputBinding:
      prefix: VERBOSITY=
      position: 2
      separate: false

  VALIDATION_STRINGENCY:
    type: ['null', string]
    inputBinding:
      prefix: VALIDATION_STRINGENCY=
      position: 2
      separate: false

  COMPRESSION_LEVEL:
    type: ['null', string]
    inputBinding:
      prefix: COMPRESSION_LEVEL=
      position: 2
      separate: false

  MAX_RECORDS_IN_RAM:
    type: ['null', string]
    inputBinding:
      prefix: MAX_RECORDS_IN_RAM=
      position: 2
      separate: false

outputs:
  bam:
    type: File
    secondaryFiles: [^.bai]
    outputBinding:
      glob: |
        ${
          if (inputs.O)
            return inputs.O;
          return null;
        }
  bai:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.O)
            return inputs.O.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '').replace(/\.bam/,'') + ".bai";
          return null;
        }
  mdmetrics:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.M)
            return inputs.M;
          return null;
        }
