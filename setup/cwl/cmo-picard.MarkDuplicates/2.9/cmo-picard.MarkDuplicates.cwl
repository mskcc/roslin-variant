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
  doap:name: cmo-picard.MarkDuplicates
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
baseCommand: [cmo_picard]
id: cmo-picard-MarkDuplicates

arguments:
- valueFrom: "MarkDuplicates"
  prefix: --cmd
  position: 0
- valueFrom: "2.9"
  prefix: --version
  position: 0

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 32000
    coresMin: 1


doc: |
  None

inputs:

  MAX_SEQS:
    type: ['null', string]
    doc: This option is obsolete. ReadEnds will always be spilled to disk. Default
      value - 50000. This option can be set to 'null' to clear the default value.
    inputBinding:
      prefix: --MAX_SEQUENCES_FOR_DISK_READ_ENDS_MAP

  MAX_FILE_HANDLES:
    type: ['null', string]
    doc: Maximum number of file handles to keep open when spilling read ends to disk.
      Set this number a little lower than the per-process maximum number of file that
      may be open. This number can be found by executing the 'ulimit -n' command on
      a Unix system. Default value - 8000. This option can be set to 'null' to clear
      the default value.
    inputBinding:
      prefix: --MAX_FILE_HANDLES_FOR_READ_ENDS_MAP

  SORTING_COLLECTION_SIZE_RATIO:
    type: ['null', string]
    doc: This number, plus the maximum RAM available to the JVM, determine the memory
      footprint used by some of the sorting collections. If you are running out of
      memory, try reducing this number. Default value - 0.25. This option can be set
      to 'null' to clear the default value.
    inputBinding:
      prefix: --SORTING_COLLECTION_SIZE_RATIO

  BARCODE_TAG:
    type: ['null', string]
    doc: Barcode SAM tag (ex. BC for 10X Genomics) Default value - null.
    inputBinding:
      prefix: --BARCODE_TAG

  READ_ONE_BARCODE_TAG:
    type: ['null', string]
    doc: Read one barcode SAM tag (ex. BX for 10X Genomics) Default value - null.
    inputBinding:
      prefix: --READ_ONE_BARCODE_TAG

  READ_TWO_BARCODE_TAG:
    type: ['null', string]
    doc: Read two barcode SAM tag (ex. BX for 10X Genomics) Default value - null.
    inputBinding:
      prefix: --READ_TWO_BARCODE_TAG

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
      prefix: --TAG_DUPLICATE_SET_MEMBERS

  REMOVE_SEQUENCING_DUPLICATES:
    type: ['null', string]
    doc: If true remove 'optical' duplicates and other duplicates that appear to have
      arisen from the sequencing process instead of the library preparation process,
      even if REMOVE_DUPLICATES is false. If REMOVE_DUPLICATES is true, all duplicates
      are removed and this option is ignored. Default value - false. This option can
      be set to 'null' to clear the default value. Possible values - {true, false}
    inputBinding:
      prefix: --REMOVE_SEQUENCING_DUPLICATES

  TAGGING_POLICY:
    type: ['null', string]
    doc: Determines how duplicate types are recorded in the DT optional attribute.
      Default value - DontTag. This option can be set to 'null' to clear the default
      value. Possible values - {DontTag, OpticalOnly, All}
    inputBinding:
      prefix: --TAGGING_POLICY

  CLEAR_DT:
    type: ['null', string]
    doc: Clear DT tag from input SAM records. Should be set to false if input SAM
      doesn't have this tag. Default true Default value - true. This option can be
      set to 'null' to clear the default value. Possible values - {true, false}
    inputBinding:
      prefix: --CLEAR_DT

  I:
    type:
    - 'null'
    - type: array
      items: File
      inputBinding:
        prefix: --I

  O:
    type: string

    doc: The output file to write marked records to Required.
    inputBinding:
      prefix: --OUTPUT

  M:
    type: string

    doc: File to write duplication metrics to Required.
    inputBinding:
      prefix: --METRICS_FILE

  REMOVE_DUPLICATES:
    type: ['null', string]
    doc: If true do not write duplicates to the output file instead of writing them
      with appropriate flags set. Default value - false. This option can be set to
      'null' to clear the default value. Possible values - {true, false}
    inputBinding:
      prefix: --REMOVE_DUPLICATES

  AS:
    type: ['null', string]
    doc: If true, assume that the input file is coordinate sorted even if the header
      says otherwise. Deprecated, used ASSUME_SORT_ORDER=coordinate instead. Default
      value - false. This option can be set to 'null' to clear the default value.
      Possible values - {true, false} Cannot be used in conjuction with option(s)
      ASSUME_SORT_ORDER (ASO)
    inputBinding:
      prefix: --ASSUME_SORTED

  ASO:
    type: ['null', string]
    doc: If not null, assume that the input file has this order even if the header
      says otherwise. Default value - null. Possible values - {unsorted, queryname,
      coordinate, duplicate, unknown} Cannot be used in conjuction with option(s)
      ASSUME_SORTED (AS)
    inputBinding:
      prefix: --ASSUME_SORT_ORDER

  DS:
    type: ['null', string]
    doc: The scoring strategy for choosing the non-duplicate among candidates. Default
      value - SUM_OF_BASE_QUALITIES. This option can be set to 'null' to clear the
      default value. Possible values - {SUM_OF_BASE_QUALITIES, TOTAL_MAPPED_REFERENCE_LENGTH,
      RANDOM}
    inputBinding:
      prefix: --DUPLICATE_SCORING_STRATEGY

  PG:
    type: ['null', string]
    doc: The program record ID for the @PG record(s) created by this program. Set
      to null to disable PG record creation. This string may have a suffix appended
      to avoid collision with other program record IDs. Default value - MarkDuplicates.
      This option can be set to 'null' to clear the default value.
    inputBinding:
      prefix: --PROGRAM_RECORD_ID

  PG_VERSION:
    type: ['null', string]
    doc: Value of VN tag of PG record to be created. If not specified, the version
      will be detected automatically. Default value - null.
    inputBinding:
      prefix: --PROGRAM_GROUP_VERSION

  PG_COMMAND:
    type: ['null', string]
    doc: Value of CL tag of PG record to be created. If not supplied the command line
      will be detected automatically. Default value - null.
    inputBinding:
      prefix: --PROGRAM_GROUP_COMMAND_LINE

  PG_NAME:
    type: ['null', string]
    doc: Value of PN tag of PG record to be created. Default value - MarkDuplicates.
      This option can be set to 'null' to clear the default value.
    inputBinding:
      prefix: --PROGRAM_GROUP_NAME

  CO:
    type: ['null', string]
    doc: Comment(s) to include in the output file's header. Default value - null.
      This option may be specified 0 or more times.
    inputBinding:
      prefix: --COMMENT

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
      prefix: --READ_NAME_REGEX

  OPTICAL_DUPLICATE_PIXEL_DISTANCE:
    type: ['null', string]
    doc: The maximum offset between two duplicate clusters in order to consider them
      optical duplicates. The default is appropriate for unpatterned versions of the
      Illumina platform. For the patterned flowcell models, 2500 is moreappropriate.
      For other platforms and models, users should experiment to find what works best.
      Default value - 100. This option can be set to 'null' to clear the default value.
    inputBinding:
      prefix: --OPTICAL_DUPLICATE_PIXEL_DISTANCE

  MAX_OPTICAL_DUPLICATE_SET_SIZE:
    type: ['null', string]
    doc: This number is the maximum size of a set of duplicate reads for which we
      will attempt to determine which are optical duplicates. Please be aware that
      if you raise this value too high and do encounter a very large set of duplicate
      reads, it will severely affect the runtime of this tool. To completely disable
      this check, set the value to -1. Default value - 300000. This option can be
      set to 'null' to clear the default value.
    inputBinding:
      prefix: --MAX_OPTICAL_DUPLICATE_SET_SIZE

  QUIET:
    type: ['null', boolean]
    default: false

    inputBinding:
      prefix: --QUIET

  CREATE_MD5_FILE:
    type: ['null', boolean]
    default: false

    inputBinding:
      prefix: --CREATE_MD5_FILE

  CREATE_INDEX:
    type: ['null', boolean]
    default: true

    inputBinding:
      prefix: --CREATE_INDEX

  TMP_DIR:
    type: ['null', string]
    inputBinding:
      prefix: --TMP_DIR

  VERBOSITY:
    type: ['null', string]
    inputBinding:
      prefix: --VERBOSITY

  VALIDATION_STRINGENCY:
    type: ['null', string]
    inputBinding:
      prefix: --VALIDATION_STRINGENCY

  COMPRESSION_LEVEL:
    type: ['null', string]
    inputBinding:
      prefix: --COMPRESSION_LEVEL

  MAX_RECORDS_IN_RAM:
    type: ['null', string]
    inputBinding:
      prefix: --MAX_RECORDS_IN_RAM

  stderr:
    type: ['null', string]
    doc: log stderr to file
    inputBinding:
      prefix: --stderr

  stdout:
    type: ['null', string]
    doc: log stdout to file
    inputBinding:
      prefix: --stdout


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
