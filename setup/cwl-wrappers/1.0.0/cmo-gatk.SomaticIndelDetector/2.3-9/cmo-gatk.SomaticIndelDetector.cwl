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
  doap:name: cmo-gatk.SomaticIndelDetector
  doap:revision: 2.3-9
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
# To generate again: $ cmo_gatk --generate_cwl_tool
# Help: $ cmo_gatk --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- cmo_gatk
- -T
- SomaticIndelDetector
- --version
- 2.3-9

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 25
    coresMin: 5


doc: |
  None

#"$BSUB -q $queue -cwd $outdir -J SID.$id.$$ -o SID.$id.$$.%J.stdout -e SID.$id.$$.%J.stderr -R \"rusage[mem=8]\" -M 12 -n 1 \"$JAVA_1_6 -Xmx4g -jar $GATK_SomaticIndel -T SomaticIndelDetector -R $Reference -I:normal $normalBamFile -I:tumor $tumorBamFile -filter 'T_COV<10||N_COV<4||T_INDEL_F<0.0001||T_INDEL_CF<0.7' -verbose $IndelVerboseOutFilename -o $IndelOutFilename -refseq $Refseq --maxNumberOfReads 100000 -rf DuplicateRead -rf FailsVendorQualityCheck -rf NotPrimaryAlignment -rf BadMate -rf MappingQualityUnavailable -rf UnmappedRead -rf BadCigar -rf MappingQuality -mmq $MAPQ -L $targetFile\"";


inputs:
  filter:
    type: string
    default: T_COV<10||N_COV<4||T_INDEL_F<0.0001||T_INDEL_CF<0.7
    inputBinding:
      prefix: -filter
  tumor_bam:
    type: File
    inputBinding:
      prefix: --input_file:tumor
    secondaryFiles: [.bai]
  normal_bam:
    type: File
    inputBinding:
      prefix: --input_file:normal
    secondaryFiles: [.bai]
  mmq:
    type: string
    default: '20'
    inputBinding:
      prefix: --min_mapping_quality_score

  cmd:
    type: ['null', string]
    default: SomaticIndelDetector

    inputBinding:
      prefix: --cmd

  java_args:
    type: ['null', string]
    default: -Xmx48g -Xms256m -XX:-UseGCOverheadLimit
    doc: args to pass to java
    inputBinding:
      prefix: --java_args

  java_temp:
    type: ['null', string]
    doc: java.io.temp_dir, if you want to set it
    inputBinding:
      prefix: --java-temp

  arg_file:
    type:
    - 'null'
    - type: array
      items: string

    doc: Reads arguments from the specified file
    inputBinding:
      prefix: --arg_file

  input_file:
    type:
    - 'null'
    - type: array
      items: File

    doc: SAM or BAM file(s)
    inputBinding:
      prefix: --input_file

  read_buffer_size:
    type:
    - 'null'
    - type: array
      items: string

    doc: Number of reads per SAM file to buffer in memory
    inputBinding:
      prefix: --read_buffer_size

  phone_home:
    type:
    - 'null'
    - type: array
      items: string

    doc: What kind of GATK run report should we generate? STANDARD is the default,
      can be NO_ET so nothing is posted to the run repository. Please see -home-and-how-does-it-affect-me#latest
      for details. (NO_ET|STANDARD|STDOUT)
    inputBinding:
      prefix: --phone_home

  gatk_key:
    type:
    - 'null'
    - type: array
      items: string

    doc: GATK Key file. Required if running with -et NO_ET. Please see -home-and-how-does-it-affect-me#latest
      for details.
    inputBinding:
      prefix: --gatk_key

  tag:
    type:
    - 'null'
    - type: array
      items: string

    doc: Arbitrary tag string to identify this GATK run as part of a group of runs,
      for later analysis
    inputBinding:
      prefix: --tag

  read_filter:
    type:
    - 'null'
    - type: array
      items: string
      inputBinding:
        prefix: --read_filter


    doc: Specify filtration criteria to apply to each read individually
  intervals:
    type:
    - 'null'
    - File

    doc: One or more genomic intervals over which to operate. Can be explicitly specified
      on the command line or in a file (including a rod file)
    inputBinding:
      prefix: --intervals

  excludeIntervals:
    type:
    - 'null'
    - type: array
      items: string

    doc: One or more genomic intervals to exclude from processing. Can be explicitly
      specified on the command line or in a file (including a rod file)
    inputBinding:
      prefix: --excludeIntervals

  interval_set_rule:
    type:
    - 'null'
    - type: array
      items: string

    doc: Indicates the set merging approach the interval parser should use to combine
      the various -L or -XL inputs (UNION| INTERSECTION)
    inputBinding:
      prefix: --interval_set_rule

  interval_merging:
    type:
    - 'null'
    - type: array
      items: string

    doc: Indicates the interval merging rule we should use for abutting intervals
      (ALL| OVERLAPPING_ONLY)
    inputBinding:
      prefix: --interval_merging

  interval_padding:
    type:
    - 'null'
    - type: array
      items: string

    doc: Indicates how many basepairs of padding to include around each of the intervals
      specified with the -L/--intervals argument
    inputBinding:
      prefix: --interval_padding

  reference_sequence:
    type:
    - string

    inputBinding:
      prefix: --reference_sequence

  nonDeterministicRandomSeed:
    type: ['null', boolean]
    default: false
    doc: Makes the GATK behave non deterministically, that is, the random numbers
      generated will be different in every run
    inputBinding:
      prefix: --nonDeterministicRandomSeed

  disableRandomization:
    type: ['null', boolean]
    default: false
    doc: Completely eliminates randomization
    inputBinding:
      prefix: --disableRandomization

  maxRuntime:
    type:
    - 'null'
    - type: array
      items: string

    doc: If provided, that GATK will stop execution cleanly as soon after maxRuntime
      has been exceeded, truncating the run but not exiting with a failure. By default
      the value is interpreted in minutes, but this can be changed by maxRuntimeUnits
    inputBinding:
      prefix: --maxRuntime

  maxRuntimeUnits:
    type:
    - 'null'
    - type: array
      items: string

    doc: The TimeUnit for maxRuntime (NANOSECONDS|MICROSECONDS|MILLISECONDS| SECONDS|MINUTES|HOURS|DAYS)
    inputBinding:
      prefix: --maxRuntimeUnits

  downsampling_type:
    type:
    - 'null'
    - type: array
      items: string

    doc: Type of reads downsampling to employ at a given locus. Reads will be selected
      randomly to be removed from the pile based on the method described here (NONE|ALL_READS|BY_SAMPLE)
    inputBinding:
      prefix: --downsampling_type

  downsample_to_fraction:
    type:
    - 'null'
    - type: array
      items: string

    doc: Fraction [0.0-1.0] of reads to downsample to
    inputBinding:
      prefix: --downsample_to_fraction

  downsample_to_coverage:
    type:
    - 'null'
    - type: array
      items: string

    doc: Coverage [integer] to downsample to at any given locus; note that downsampled
      reads are randomly selected from all possible reads at a locus. For non-locus-based
      traversals (eg., ReadWalkers), this sets the maximum number of reads at each
      alignment start position.
    inputBinding:
      prefix: --downsample_to_coverage

  use_legacy_downsampler:
    type: ['null', boolean]
    default: false
    doc: Use the legacy downsampling implementation instead of the newer, less-tested
      implementation
    inputBinding:
      prefix: --use_legacy_downsampler

  baq:
    type:
    - 'null'
    - type: array
      items: string

    doc: Type of BAQ calculation to apply in the engine (OFF|CALCULATE_AS_NECESSARY|
      RECALCULATE)
    inputBinding:
      prefix: --baq

  baqGapOpenPenalty:
    type:
    - 'null'
    - type: array
      items: string

    doc: BAQ gap open penalty (Phred Scaled). Default value is 40. 30 is perhaps better
      for whole genome call sets
    inputBinding:
      prefix: --baqGapOpenPenalty

  fix_misencoded_quality_scores:
    type: ['null', boolean]
    default: false
    doc: Fix mis-encoded base quality scores
    inputBinding:
      prefix: --fix_misencoded_quality_scores

  allow_potentially_misencoded_quality_scores:
    type: ['null', boolean]
    default: false
    doc: Do not fail when encountered base qualities that are too high and seemingly
      indicate a problem with the base quality encoding of the BAM file
    inputBinding:
      prefix: --allow_potentially_misencoded_quality_scores

  performanceLog:
    type:
    - 'null'
    - type: array
      items: string

    doc: If provided, a GATK runtime performance log will be written to this file
    inputBinding:
      prefix: --performanceLog

  useOriginalQualities:
    type: ['null', boolean]
    default: false
    doc: If set, use the original base quality scores from the OQ tag when present
      instead of the standard scores
    inputBinding:
      prefix: --useOriginalQualities

  BQSR:
    type:
    - 'null'
    - type: array
      items: string

    doc: The input covariates table file which enables on-the-fly base quality score
      recalibration
    inputBinding:
      prefix: --BQSR

  disable_indel_quals:
    type: ['null', boolean]
    default: false
    doc: If true, disables printing of base insertion and base deletion tags (with
      -BQSR)
    inputBinding:
      prefix: --disable_indel_quals

  emit_original_quals:
    type: ['null', boolean]
    default: false
    doc: If true, enables printing of the OQ tag with the original base qualities
      (with -BQSR)
    inputBinding:
      prefix: --emit_original_quals

  preserve_qscores_less_than:
    type:
    - 'null'
    - type: array
      items: string

    doc: Bases with quality scores less than this threshold won't be recalibrated
      (with -BQSR)
    inputBinding:
      prefix: --preserve_qscores_less_than

  defaultBaseQualities:
    type:
    - 'null'
    - type: array
      items: string

    doc: If reads are missing some or all base quality scores, this value will be
      used for all base quality scores
    inputBinding:
      prefix: --defaultBaseQualities

  validation_strictness:
    type:
    - 'null'
    - type: array
      items: string

    doc: How strict should we be with validation (STRICT|LENIENT|SILENT)
    inputBinding:
      prefix: --validation_strictness

  remove_program_records:
    type: ['null', boolean]
    default: false
    doc: Should we override the Walker's default and remove program records from the
      SAM header
    inputBinding:
      prefix: --remove_program_records

  keep_program_records:
    type: ['null', boolean]
    default: false
    doc: Should we override the Walker's default and keep program records from the
      SAM header
    inputBinding:
      prefix: --keep_program_records

  unsafe:
    type:
    - 'null'
    - type: array
      items: string

    doc: If set, enables unsafe operations - nothing will be checked at runtime. For
      expert users only who know what they are doing. We do not support usage of this
      argument. (ALLOW_UNINDEXED_BAM| ALLOW_UNSET_BAM_SORT_ORDER| NO_READ_ORDER_VERIFICATION|
      ALLOW_SEQ_DICT_INCOMPATIBILITY| LENIENT_VCF_PROCESSING|ALL)
    inputBinding:
      prefix: --unsafe

  num_threads:
    type:
    - 'null'
    - type: array
      items: string

    doc: How many data threads should be allocated to running this analysis.
    inputBinding:
      prefix: --num_threads

  num_cpu_threads_per_data_thread:
    type:
    - 'null'
    - type: array
      items: string

    doc: How many CPU threads should be allocated per data thread to running this
      analysis?
    inputBinding:
      prefix: --num_cpu_threads_per_data_thread

  monitorThreadEfficiency:
    type: ['null', boolean]
    default: false
    doc: Enable GATK threading efficiency monitoring
    inputBinding:
      prefix: --monitorThreadEfficiency

  num_bam_file_handles:
    type:
    - 'null'
    - type: array
      items: string

    doc: The total number of BAM file handles to keep open simultaneously
    inputBinding:
      prefix: --num_bam_file_handles

  read_group_black_list:
    type:
    - 'null'
    - type: array
      items: string

    doc: Filters out read groups matching <TAG> -<STRING> or a .txt file containing
      the filter strings one per line.
    inputBinding:
      prefix: --read_group_black_list

  pedigree:
    type:
    - 'null'
    - type: array
      items: string

    doc: Pedigree files for samples
    inputBinding:
      prefix: --pedigree

  pedigreeString:
    type:
    - 'null'
    - type: array
      items: string

    doc: Pedigree string for samples
    inputBinding:
      prefix: --pedigreeString

  pedigreeValidationType:
    type:
    - 'null'
    - type: array
      items: string

    doc: How strict should we be in validating the pedigree information? (STRICT|
      SILENT)
    inputBinding:
      prefix: --pedigreeValidationType

  logging_level:
    type:
    - 'null'
    - type: array
      items: string

    doc: Set the minimum level of logging, i.e. setting INFO get's you INFO up to
      FATAL, setting ERROR gets you ERROR and FATAL level logging.
    inputBinding:
      prefix: --logging_level

  log_to_file:
    type:
    - 'null'
    - type: array
      items: string

    doc: Set the logging location
    inputBinding:
      prefix: --log_to_file

  filter_mismatching_base_and_quals:
    type: ['null', boolean]
    default: false
    doc: if a read has mismatching number of bases and base qualities, filter out
      the read instead of blowing up.
    inputBinding:
      prefix: --filter_mismatching_base_and_quals

  out:
    type:
    - 'null'
    - string

    doc: File to write variants (indels) in VCF format
    inputBinding:
      prefix: --out

  metrics_file:
    type:
    - 'null'
    - type: array
      items: string

    doc: File to print callability metrics output
    inputBinding:
      prefix: --metrics_file

  verboseOutput:
    type:
    - 'null'
    - string
    doc: Verbose output file in text format
    inputBinding:
      prefix: --verboseOutput

  bedOutput:
    type:
    - 'null'
    - type: array
      items: string

    doc: Lightweight bed output file (only positions and events, no stats/annotations)
    inputBinding:
      prefix: --bedOutput

  refseq:
    type:
    - 'null'
    - File

    doc: Name of RefSeq transcript annotation file. If specified, indels will be annotated
      with GENOMIC/UTR/INTRON/CODING and with the gene name
    inputBinding:
      prefix: --refseq

  filter_expressions:
    type:
    - 'null'
    - type: array
      items: string

    doc: One or more logical expressions. If any of the expressions is TRUE, putative
      indel will be discarded and nothing will be printed into the output (unless
      genotyping at the specific position is explicitly requested, see -genotype).
      Default - T_COV<6||N_COV<4|| T_INDEL_F<0.3||T_INDEL_CF<0.7
    inputBinding:
      prefix: --filter_expressions

  window_size:
    type:
    - 'null'
    - type: array
      items: string

    doc: Size (bp) of the sliding window used for accumulating the coverage. May need
      to be increased to accomodate longer reads or longer deletions. A read can be
      fit into the window if its length on the reference (i.e. read length + length
      of deletion gap(s) if any) is smaller than the window size. Reads that do not
      fit will be ignored, so long deletions can not be called if window is too small
    inputBinding:
      prefix: --window_size

  maxNumberOfReads:
    type:
    - 'null'
    - string
    default: '100000'
    doc: Maximum number of reads to cache in the window; if number of reads exceeds
      this number, the window will be skipped and no calls will be made from it
    inputBinding:
      prefix: --maxNumberOfReads

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
  output:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.out)
            return inputs.out;
          return null;
        }
  verbose_output:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.verboseOutput)
            return inputs.verboseOutput;
          return null;
        }
