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
  doap:name: cmo-gatk.BaseRecalibrator
  doap:revision: 3.3-0
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

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand: [cmo_gatk]

arguments:
- -T
- BaseRecalibrator
- --version
- 3.3-0

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 24
    coresMin: 2

doc: |
  None

inputs:
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
      inputBinding:
        prefix: --input_file
    doc: Input file containing sequence data (SAM or BAM)

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
    doc: Run reporting mode (NO_ET|AWS|STDOUT)
    inputBinding:
      prefix: --phone_home

  gatk_key:
    type:
    - 'null'
    - type: array
      items: string
    doc: GATK key file required to run with -et NO_ET
    inputBinding:
      prefix: --gatk_key

  tag:
    type:
    - 'null'
    - type: array
      items: string
    doc: Tag to identify this GATK run as part of a group of runs
    inputBinding:
      prefix: --tag

  read_filter:
    type:
    - 'null'
    - type: array
      items: string
    doc: Filters to apply to reads before analysis
    inputBinding:
      prefix: --read_filter

  intervals:
    type:
    - 'null'
    - type: array
      items: string
    doc: One or more genomic intervals over which to operate
    inputBinding:
      prefix: --intervals

  excludeIntervals:
    type:
    - 'null'
    - type: array
      items: string
    doc: One or more genomic intervals to exclude from processing
    inputBinding:
      prefix: --excludeIntervals

  interval_set_rule:
    type:
    - 'null'
    - type: array
      items: string
    doc: Set merging approach to use for combining interval inputs (UNION|INTERSECTION)
    inputBinding:
      prefix: --interval_set_rule

  interval_merging:
    type:
    - 'null'
    - type: array
      items: string
    doc: Interval merging rule for abutting intervals (ALL| OVERLAPPING_ONLY)
    inputBinding:
      prefix: --interval_merging

  interval_padding:
    type:
    - 'null'
    - type: array
      items: string
    doc: Amount of padding (in bp) to add to each interval
    inputBinding:
      prefix: --interval_padding

  reference_sequence:
    type:
    - 'null'
    - string
    inputBinding:
      prefix: --reference_sequence

  nonDeterministicRandomSeed:
    type: ['null', boolean]
    default: false
    doc: Use a non-deterministic random seed
    inputBinding:
      prefix: --nonDeterministicRandomSeed

  maxRuntime:
    type:
    - 'null'
    - type: array
      items: string
    doc: Stop execution cleanly as soon as maxRuntime has been reached
    inputBinding:
      prefix: --maxRuntime

  maxRuntimeUnits:
    type:
    - 'null'
    - type: array
      items: string
    doc: Unit of time used by maxRuntime (NANOSECONDS|MICROSECONDS| MILLISECONDS|SECONDS|MINUTES|
      HOURS|DAYS)
    inputBinding:
      prefix: --maxRuntimeUnits

  downsampling_type:
    type:
    - 'null'
    - type: array
      items: string
    doc: Type of read downsampling to employ at a given locus (NONE|ALL_READS|BY_SAMPLE)
    inputBinding:
      prefix: --downsampling_type

  downsample_to_fraction:
    type:
    - 'null'
    - type: array
      items: string
    doc: Fraction of reads to downsample to
    inputBinding:
      prefix: --downsample_to_fraction

  downsample_to_coverage:
    type:
    - 'null'
    - type: array
      items: string
    doc: Target coverage threshold for downsampling to coverage
    inputBinding:
      prefix: --downsample_to_coverage

  baq:
    type:
    - 'null'
    - type: array
      items: string
    doc: Type of BAQ calculation to apply in the engine (OFF| CALCULATE_AS_NECESSARY|
      RECALCULATE)
    inputBinding:
      prefix: --baq

  baqGapOpenPenalty:
    type:
    - 'null'
    - type: array
      items: string
    doc: BAQ gap open penalty
    inputBinding:
      prefix: --baqGapOpenPenalty

  refactor_NDN_cigar_string:
    type: ['null', boolean]
    default: false
    doc: refactor cigar string with NDN elements to one element
    inputBinding:
      prefix: --refactor_NDN_cigar_string

  fix_misencoded_quality_scores:
    type: ['null', boolean]
    default: false
    doc: Fix mis-encoded base quality scores
    inputBinding:
      prefix: --fix_misencoded_quality_scores

  allow_potentially_misencoded_quality_scores:
    type: ['null', boolean]
    default: false
    doc: Ignore warnings about base quality score encoding
    inputBinding:
      prefix: --allow_potentially_misencoded_quality_scores

  useOriginalQualities:
    type: ['null', boolean]
    default: false
    doc: Use the base quality scores from the OQ tag
    inputBinding:
      prefix: --useOriginalQualities

  defaultBaseQualities:
    type:
    - 'null'
    - type: array
      items: string
    doc: Assign a default base quality
    inputBinding:
      prefix: --defaultBaseQualities

  performanceLog:
    type:
    - 'null'
    - type: array
      items: string
    doc: Write GATK runtime performance log to this file
    inputBinding:
      prefix: --performanceLog

  BQSR:
    type:
    - 'null'
    - type: array
      items: string
    doc: Input covariates table file for on-the-fly base quality score recalibration
    inputBinding:
      prefix: --BQSR

  disable_indel_quals:
    type: ['null', boolean]
    default: false
    doc: Disable printing of base insertion and deletion tags (with -BQSR)
    inputBinding:
      prefix: --disable_indel_quals

  emit_original_quals:
    type: ['null', boolean]
    default: false
    doc: Emit the OQ tag with the original base qualities (with -BQSR)
    inputBinding:
      prefix: --emit_original_quals

  preserve_qscores_less_than:
    type:
    - 'null'
    - type: array
      items: string
    doc: Don't recalibrate bases with quality scores less than this threshold (with
      -BQSR)
    inputBinding:
      prefix: --preserve_qscores_less_than

  globalQScorePrior:
    type:
    - 'null'
    - type: array
      items: string
    doc: Global Qscore Bayesian prior to use for BQSR
    inputBinding:
      prefix: --globalQScorePrior

  validation_strictness:
    type:
    - 'null'
    - type: array
      items: string
    doc: How strict should we be with validation (STRICT|LENIENT| SILENT)
    inputBinding:
      prefix: --validation_strictness

  remove_program_records:
    type: ['null', boolean]
    default: false
    doc: Remove program records from the SAM header
    inputBinding:
      prefix: --remove_program_records

  keep_program_records:
    type: ['null', boolean]
    default: false
    doc: Keep program records in the SAM header
    inputBinding:
      prefix: --keep_program_records

  sample_rename_mapping_file:
    type:
    - 'null'
    - type: array
      items: string
    doc: Rename sample IDs on-the-fly at runtime using the provided mapping file
    inputBinding:
      prefix: --sample_rename_mapping_file

  unsafe:
    type:
    - 'null'
    - type: array
      items: string
    doc: Enable unsafe operations - nothing will be checked at runtime (ALLOW_N_CIGAR_READS|
      ALLOW_UNINDEXED_BAM| ALLOW_UNSET_BAM_SORT_ORDER| NO_READ_ORDER_VERIFICATION|
      ALLOW_SEQ_DICT_INCOMPATIBILITY| LENIENT_VCF_PROCESSING|ALL)
    inputBinding:
      prefix: --unsafe

  sites_only:
    type: ['null', boolean]
    default: false
    doc: Just output sites without genotypes (i.e. only the first 8 columns of the VCF)
    inputBinding:
      prefix: --sites_only

  never_trim_vcf_format_field:
    type: ['null', boolean]
    default: false
    doc: Always output all the records in VCF FORMAT fields, even if some are missing
    inputBinding:
      prefix: --never_trim_vcf_format_field

  bam_compression:
    type:
    - 'null'
    - type: array
      items: string
    doc: Compression level to use for writing BAM files (0 - 9, higher is more compressed)
    inputBinding:
      prefix: --bam_compression

  simplifyBAM:
    type: ['null', boolean]
    default: false
    doc: If provided, output BAM files will be simplified to include just key reads
      for downstream variation discovery analyses (removing duplicates, PF-, non-primary
      reads), as well stripping all extended tags from the kept reads except the read
      group identifier
    inputBinding:
      prefix: --simplifyBAM

  disable_bam_indexing:
    type: ['null', boolean]
    default: false
    doc: Turn off on-the-fly creation of
    inputBinding:
      prefix: --disable_bam_indexing

  generate_md5:
    type: ['null', boolean]
    default: false
    doc: Enable on-the-fly creation of
    inputBinding:
      prefix: --generate_md5

  num_threads:
    type:
    - 'null'
    - string
    doc: Number of data threads to allocate to this analysis
    inputBinding:
      prefix: --num_threads

  num_cpu_threads_per_data_thread:
    type:
    - 'null'
    - string
    default: '2'
    doc: Number of CPU threads to allocate per data thread
    inputBinding:
      prefix: --num_cpu_threads_per_data_thread

  monitorThreadEfficiency:
    type: ['null', boolean]
    default: false
    doc: Enable threading efficiency monitoring
    inputBinding:
      prefix: --monitorThreadEfficiency

  num_bam_file_handles:
    type:
    - 'null'
    - type: array
      items: string
    doc: Total number of BAM file handles to keep open simultaneously
    inputBinding:
      prefix: --num_bam_file_handles

  read_group_black_list:
    type:
    - 'null'
    - type: array
      items: string
    doc: Exclude read groups based on tags
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
    doc: Validation strictness for pedigree information (STRICT| SILENT)
    inputBinding:
      prefix: --pedigreeValidationType

  variant_index_type:
    type:
    - 'null'
    - type: array
      items: string
    doc: Type of IndexCreator to use for VCF/BCF indices (DYNAMIC_SEEK| DYNAMIC_SIZE|LINEAR|INTERVAL)
    inputBinding:
      prefix: --variant_index_type

  variant_index_parameter:
    type:
    - 'null'
    - type: array
      items: string
    doc: Parameter to pass to the VCF/BCF IndexCreator
    inputBinding:
      prefix: --variant_index_parameter

  logging_level:
    type:
    - 'null'
    - type: array
      items: string
    doc: Set the minimum level of logging
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

  out:
    type:
    - 'null'
    - string
    doc: The output recalibration table file to create
    inputBinding:
      prefix: --out

  knownSites:
    type:
      type: array
      items: File
      inputBinding:
        prefix: --knownSites
    doc: A database of known polymorphic sites to skip over in the recalibration algorithm
    secondaryFiles:
    - .idx

  list:
    type: ['null', boolean]
    default: false
    doc: List the available covariates and exit
    inputBinding:
      prefix: --list

  covariate:
    type:
      type: array
      items: string
      inputBinding:
        prefix: --covariate
    doc: One or more covariates to be used in the recalibration. Can be specified
      multiple times

  no_standard_covs:
    type: ['null', boolean]
    default: false
    doc: Do not use the standard set of covariates, but rather just the ones listed
      using the -cov argumentthout_dbsnp_potentially_ruining_quality,--run_without_dbsnp_potentially_ruining_quality
      If specified, allows the recalibrator to be used without a dbsnp rod. Very unsafe
      and for expert users only.
    inputBinding:
      prefix: --no_standard_covs

  solid_recal_mode:
    type:
    - 'null'
    - type: array
      items: string
    doc: How should we recalibrate solid bases in which the reference was inserted?
      Options = DO_NOTHING, SET_Q_ZERO, SET_Q_ZERO_BASE_N, or REMOVE_REF_BIAS (DO_NOTHING|
      SET_Q_ZERO|SET_Q_ZERO_BASE_N| REMOVE_REF_BIAS)
    inputBinding:
      prefix: --solid_recal_mode

  solid_nocall_strategy:
    type:
    - 'null'
    - type: array
      items: string
    doc: Defines the behavior of the recalibrator when it encounters no calls in the
      color space. Options = THROW_EXCEPTION, LEAVE_READ_UNRECALIBRATED, or PURGE_READ
      (THROW_EXCEPTION| LEAVE_READ_UNRECALIBRATED| PURGE_READ)
    inputBinding:
      prefix: --solid_nocall_strategy

  mismatches_context_size:
    type:
    - 'null'
    - type: array
      items: string
    doc: Size of the k-mer context to be used for base mismatches
    inputBinding:
      prefix: --mismatches_context_size

  indels_context_size:
    type:
    - 'null'
    - type: array
      items: string

    doc: Size of the k-mer context to be used for base insertions and deletions
    inputBinding:
      prefix: --indels_context_size

  maximum_cycle_value:
    type:
    - 'null'
    - type: array
      items: string

    doc: The maximum cycle value permitted for the Cycle covariate
    inputBinding:
      prefix: --maximum_cycle_value

  mismatches_default_quality:
    type:
    - 'null'
    - type: array
      items: string

    doc: default quality for the base mismatches covariate
    inputBinding:
      prefix: --mismatches_default_quality

  insertions_default_quality:
    type:
    - 'null'
    - type: array
      items: string

    doc: default quality for the base insertions covariate
    inputBinding:
      prefix: --insertions_default_quality

  deletions_default_quality:
    type:
    - 'null'
    - type: array
      items: string

    doc: default quality for the base deletions covariate
    inputBinding:
      prefix: --deletions_default_quality

  low_quality_tail:
    type:
    - 'null'
    - type: array
      items: string

    doc: minimum quality for the bases in the tail of the reads to be considered
    inputBinding:
      prefix: --low_quality_tail

  quantizing_levels:
    type:
    - 'null'
    - type: array
      items: string

    doc: number of distinct quality scores in the quantized output
    inputBinding:
      prefix: --quantizing_levels

  binary_tag_name:
    type:
    - 'null'
    - type: array
      items: string

    doc: the binary tag covariate name if using it
    inputBinding:
      prefix: --binary_tag_name

  sort_by_all_columns:
    type: ['null', boolean]
    default: false
    doc: Sort the rows in the tables of reports
    inputBinding:
      prefix: --sort_by_all_columns

  lowMemoryMode:
    type: ['null', boolean]
    default: false
    doc: Reduce memory usage in multi-threaded code at the expense of threading efficiency
    inputBinding:
      prefix: --lowMemoryMode

  bqsrBAQGapOpenPenalty:
    type:
    - 'null'
    - type: array
      items: string

    doc: BQSR BAQ gap open penalty (Phred Scaled). Default value is 40. 30 is perhaps
      better for whole genome call sets
    inputBinding:
      prefix: --bqsrBAQGapOpenPenalty

  filter_reads_with_N_cigar:
    type: ['null', boolean]
    default: false
    doc: filter out reads with CIGAR containing the N operator, instead of stop processing
      and report an error.
    inputBinding:
      prefix: --filter_reads_with_N_cigar

  filter_mismatching_base_and_quals:
    type: ['null', boolean]
    default: false
    doc: if a read has mismatching number of bases and base qualities, filter out
      the read instead of blowing up.
    inputBinding:
      prefix: --filter_mismatching_base_and_quals

  filter_bases_not_stored:
    type: ['null', boolean]
    default: false
    doc: if a read has no stored bases (i.e. a '*'), filter out the read instead of
      blowing up.
    inputBinding:
      prefix: --filter_bases_not_stored

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
  recal_matrix:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.out)
            return inputs.out;
          return null;
        }
