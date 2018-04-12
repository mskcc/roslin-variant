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
  doap:name: cmo-mutect
  doap:revision: 1.1.4
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
baseCommand:
- cmo_mutect
- --version
- "1.1.4"
- --java-version
- "jdk1.6.0_45"

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 24
    coresMin: 1

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

  input_file_normal:
    type:
    - 'null'
    - File

    doc: SAM or BAM file(s)
    inputBinding:
      prefix: --input_file:normal
    secondaryFiles: [.bai]

  input_file_tumor:
    type:
    - 'null'
    - File

    doc: SAM or BAM file(s)
    inputBinding:
      prefix: --input_file:tumor
    secondaryFiles: [.bai]

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
      can be NO_ET so nothing is posted to the run repository. Please see -phone-home-and-how-does-it-affect-me#latest
      for details. (NO_ET|STANDARD|STDOUT)
    inputBinding:
      prefix: --phone_home

  gatk_key:
    type:
    - 'null'
    - type: array
      items: string

    doc: GATK Key file. Required if running with -et NO_ET. Please see -phone-home-and-how-does-it-affect-me#latest
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

    doc: Specify filtration criteria to apply to each read individually
    inputBinding:
      prefix: --read_filter

  intervals:
    type:
    - 'null'
    - string
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
      specified with the -L/
    inputBinding:
      prefix: --interval_padding

  reference_sequence:
    type: string

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
    doc: Completely eliminates randomization from nondeterministic methods. To be
      used mostly in the testing framework where dynamic parallelism can result in
      differing numbers of calls to the generator.
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

    doc: The TimeUnit for maxRuntime (NANOSECONDS| MICROSECONDS|MILLISECONDS|SECONDS|MINUTES|
      HOURS|DAYS)
    inputBinding:
      prefix: --maxRuntimeUnits

  enable_extended_output:
    type: boolean
    default: true
    inputBinding:
      prefix: --enable_extended_output

  downsampling_type:
    type:
    - 'null'
    - string
    default: NONE
    doc: Type of reads downsampling to employ at a given locus. Reads will be selected
      randomly to be removed from the pile based on the method described here (NONE|ALL_READS|
      BY_SAMPLE) given locus; note that downsampled reads are randomly selected from
      all possible reads at a locus
    inputBinding:
      prefix: --downsampling_type

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
    - string
    doc: How many data threads should be allocated to running this analysis.
    inputBinding:
      prefix: --num_threads

  num_cpu_threads_per_data_thread:
    type:
    - 'null'
    - string
    doc: How many CPU threads should be allocated per data thread to running this analysis?
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

    doc: How strict should we be in validating the pedigree information? (STRICT|SILENT)
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

  noop:
    type: ['null', boolean]
    default: false
    doc: used for debugging, basically exit as soon as we get the reads
    inputBinding:
      prefix: --noop

  tumor_sample_name:
    type:
    - 'null'
    - type: array
      items: string

    doc: name to use for tumor in output files
    inputBinding:
      prefix: --tumor_sample_name

  bam_tumor_sample_name:
    type:
    - 'null'
    - type: array
      items: string

    doc: if the tumor bam contains multiple samples, only use read groups with SM
      equal to this value
    inputBinding:
      prefix: --bam_tumor_sample_name

  normal_sample_name:
    type:
    - 'null'
    - type: array
      items: string

    doc: name to use for normal in output files
    inputBinding:
      prefix: --normal_sample_name

  force_output:
    type: ['null', boolean]
    default: false
    doc: force output for each site
    inputBinding:
      prefix: --force_output

  force_alleles:
    type: ['null', boolean]
    default: false
    doc: force output for all alleles at each site
    inputBinding:
      prefix: --force_alleles

  only_passing_calls:
    type: ['null', boolean]
    default: false
    doc: only emit passing calls
    inputBinding:
      prefix: --only_passing_calls

  initial_tumor_lod:
    type:
    - 'null'
    - type: array
      items: string

    doc: Initial LOD threshold for calling tumor variant
    inputBinding:
      prefix: --initial_tumor_lod

  tumor_lod:
    type:
    - 'null'
    - type: array
      items: string

    doc: LOD threshold for calling tumor variant
    inputBinding:
      prefix: --tumor_lod

  fraction_contamination:
    type:
    - 'null'
    - type: array
      items: string

    doc: estimate of fraction (0-1) of physical contamination with other unrelated
      samples
    inputBinding:
      prefix: --fraction_contamination

  minimum_mutation_cell_fraction:
    type:
    - 'null'
    - type: array
      items: string

    doc: minimum fraction of cells which are presumed to have a mutation, used to
      handle non-clonality and contamination
    inputBinding:
      prefix: --minimum_mutation_cell_fraction

  normal_lod:
    type:
    - 'null'
    - type: array
      items: string

    doc: LOD threshold for calling normal non-germline
    inputBinding:
      prefix: --normal_lod

  dbsnp_normal_lod:
    type:
    - 'null'
    - type: array
      items: string

    doc: LOD threshold for calling normal non-variant at dbsnp sites
    inputBinding:
      prefix: --dbsnp_normal_lod

  somatic_classification_normal_power_threshold:
    type: ['null', boolean]
    default: false
    doc: Power threshold for normal to <somatic_classification_normal_power_threshold>
      determine germline vs variant
    inputBinding:
      prefix: --somatic_classification_normal_power_threshold

  minimum_normal_allele_fraction:
    type:
    - 'null'
    - type: array
      items: string

    doc: minimum allele fraction to be considered in normal, useful for normal sample
      contaminated with tumor
    inputBinding:
      prefix: --minimum_normal_allele_fraction

  tumor_f_pretest:
    type:
    - 'null'
    - type: array
      items: string

    doc: for computational efficiency, reject sites with allelic fraction below this
      threshold
    inputBinding:
      prefix: --tumor_f_pretest

  min_qscore:
    type:
    - 'null'
    - type: array
      items: string

    doc: threshold for minimum base quality score
    inputBinding:
      prefix: --min_qscore

  gap_events_threshold:
    type:
    - 'null'
    - type: array
      items: string

    doc: how many gapped events (ins/del) are allowed in proximity to this candidate
    inputBinding:
      prefix: --gap_events_threshold

  heavily_clipped_read_fraction:
    type:
    - 'null'
    - type: array
      items: string

    doc: if this fraction or more of the bases in a read are soft/hard clipped, do
      not use this read for mutation calling
    inputBinding:
      prefix: --heavily_clipped_read_fraction

  clipping_bias_pvalue_threshold:
    type:
    - 'null'
    - type: array
      items: string

    doc: pvalue threshold for fishers exact test of clipping bias in mutant reads
      vs ref reads
    inputBinding:
      prefix: --clipping_bias_pvalue_threshold

  fraction_mapq0_threshold:
    type:
    - 'null'
    - type: array
      items: string

    doc: threshold for determining if there is relatedness between the alt and ref
      allele read piles
    inputBinding:
      prefix: --fraction_mapq0_threshold

  pir_median_threshold:
    type:
    - 'null'
    - type: array
      items: string

    doc: threshold for clustered read position artifact median
    inputBinding:
      prefix: --pir_median_threshold

  pir_mad_threshold:
    type:
    - 'null'
    - type: array
      items: string

    doc: threshold for clustered read position artifact MAD
    inputBinding:
      prefix: --pir_mad_threshold

  required_maximum_alt_allele_mapping_quality_score:
    type: ['null', boolean]
    default: false
    doc: required minimum value for <required_maximum_alt_allele_mapping_quality_score>
      tumor alt allele maximum mapping quality score
    inputBinding:
      prefix: --required_maximum_alt_allele_mapping_quality_score

  max_alt_alleles_in_normal_count:
    type:
    - 'null'
    - type: array
      items: string

    doc: threshold for maximum alternate allele counts in normal
    inputBinding:
      prefix: --max_alt_alleles_in_normal_count

  max_alt_alleles_in_normal_qscore_sum:
    type:
    - 'null'
    - type: array
      items: string

    doc: threshold for maximum alternate allele quality score sum in normal
    inputBinding:
      prefix: --max_alt_alleles_in_normal_qscore_sum

  max_alt_allele_in_normal_fraction:
    type:
    - 'null'
    - type: array
      items: string

    doc: threshold for maximum alternate allele fraction in normal
    inputBinding:
      prefix: --max_alt_allele_in_normal_fraction

  power_constant_qscore:
    type:
    - 'null'
    - type: array
      items: string

    doc: Phred scale quality score constant to use in power calculations
    inputBinding:
      prefix: --power_constant_qscore

  absolute_copy_number_data:
    type:
    - 'null'
    - type: array
      items: string

    doc: Absolute Copy Number Data, as defined by Absolute, to use in power calculations
    inputBinding:
      prefix: --absolute_copy_number_data

  power_constant_af:
    type:
    - 'null'
    - type: array
      items: string

    doc: Allelic fraction constant to use in power calculations
    inputBinding:
      prefix: --power_constant_af

  out:
    type:
    - 'null'
    - string
    - File
    doc: Call-stats output
    inputBinding:
      prefix: --out

  vcf:
    type:
    - 'null'
    - string

    doc: VCF output of mutation candidates
    inputBinding:
      prefix: --vcf

  dbsnp:
    type:
    - 'null'
    - File

    doc: VCF file of DBSNP information
    inputBinding:
      prefix: --dbsnp
    secondaryFiles: [^.vcf.idx]

  cosmic:
    type:
    - 'null'
    - File

    doc: VCF file of COSMIC sites
    inputBinding:
      prefix: --cosmic
    secondaryFiles: [^.vcf.idx]

  coverage_file:
    type:
    - 'null'
    - type: array
      items: string

    doc: write out coverage in WIGGLE format to this file
    inputBinding:
      prefix: --coverage_file

  coverage_20_q20_file:
    type:
    - 'null'
    - type: array
      items: string

    doc: write out 20x of Q20 coverage in WIGGLE format to this file
    inputBinding:
      prefix: --coverage_20_q20_file

  power_file:
    type:
    - 'null'
    - type: array
      items: string

    doc: write out power in WIGGLE format to this file
    inputBinding:
      prefix: --power_file

  tumor_depth_file:
    type:
    - 'null'
    - type: array
      items: string

    doc: write out tumor read depth in WIGGLE format to this file
    inputBinding:
      prefix: --tumor_depth_file

  normal_depth_file:
    type:
    - 'null'
    - type: array
      items: string

    doc: write out normal read depth in WIGGLE format to this file
    inputBinding:
      prefix: --normal_depth_file

  filter_mismatching_base_and_quals:
    type: ['null', boolean]
    default: false
    doc: if a read has mismatching number of bases and base qualities, filter out
      the read instead of blowing up.
    inputBinding:
      prefix: --filter_mismatching_base_and_quals



  downsample_to_coverage:
    type: ['null', int]
    doc: Target coverage threshold for downsampling to coverage
    inputBinding:
      prefix: --downsample_to_coverage

outputs:
  output:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.vcf)
            return inputs.vcf;
          return null;
        }
  callstats_output:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.out)
            return inputs.out;
          return null;
        }
