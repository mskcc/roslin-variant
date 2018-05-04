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
  doap:revision: 1.129
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
# To generate again: $ cmo_picard_mark_dup --generate_cwl_tool
# Help: $ cmo_picard_mark_dup --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand: [cmo_picard]

arguments:
- --cmd
- MarkDuplicates

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 32
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
    doc: Comment(s) to include in the output file's header. This option may be specified
      0 or more times.
    inputBinding:
      prefix: --COMMENT

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
      says otherwise. Default value - false. This option can be set to 'null' to clear
      the default value. Possible values - {true, false}
    inputBinding:
      prefix: --ASSUME_SORTED

  DS:
    type: ['null', string]
    doc: The scoring strategy for choosing the non-duplicate among candidates. Default
      value - SUM_OF_BASE_QUALITIES. This option can be set to 'null' to clear the
      default value. Possible values - {SUM_OF_BASE_QUALITIES, TOTAL_MAPPED_REFERENCE_LENGTH}
    inputBinding:
      prefix: --DUPLICATE_SCORING_STRATEGY

  READ_NAME_REGEX:
    type: ['null', string]
    doc: Regular expression that can be used to parse read names in the incoming SAM
      file. Read names are parsed to extract three variables - tile/region, x coordinate
      and y coordinate. These values are used to estimate the rate of optical duplication
      in order to give a more accurate estimated library size. Set this option to
      null to disable optical duplicate detection. The regular expression should contain
      three capture groups for the three variables, in order. It must match the entire
      read name. Note that if the default regex is specified, a regex match is not
      actually done, but instead the read name is split on colon character. For 5
      element names, the 3rd, 4th and 5th elements are assumed to be tile, x and y
      values. For 7 element names (CASAVA 1.8), the 5th, 6th, and 7th elements are
      assumed to be tile, x and y values. Default value - [a-zA-Z0-9]+ -[0-9] -([0-9]+)
      -([0-9]+) -([0-9]+).*. This option can be set to 'null' to clear the default
      value.
    inputBinding:
      prefix: --READ_NAME_REGEX

  OPTICAL_DUPLICATE_PIXEL_DISTANCE:
    type: ['null', string]
    doc: The maximum offset between two duplicte clusters in order to consider them
      optical duplicates. This should usually be set to some fairly small number (e.g.
      5-10 pixels) unless using later versions of the Illumina pipeline that multiply
      pixel values by 10, in which case 50-100 is more normal. Default value - 100.
      This option can be set to 'null' to clear the default value.
    inputBinding:
      prefix: --OPTICAL_DUPLICATE_PIXEL_DISTANCE

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
