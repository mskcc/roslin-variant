#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_gatk --generate_cwl_tool
# Help: $ cmo_gatk --help_arg2cwl

cwlVersion: "cwl:v1.0"
requirements:
  InlineJavascriptRequirement: {}

class: CommandLineTool
baseCommand: ['cmo_gatk','-T','DepthOfCoverage','--version','3.3-0']

doc: |
  None

inputs:
  
  version:
    type:
    - "null"
    - type: enum
      symbols: ['default', '3.3-0', '3.4-0', '2.3-9', '3.2-2']
  
    inputBinding:
      prefix: --version 

  java_version:
    type:
    - "null"
    - type: enum
      symbols: ['default', 'jdk1.8.0_25', 'jdk1.7.0_75', 'jdk1.8.0_31', 'jre1.7.0_75']
    default: default
  
    inputBinding:
      prefix: --java-version 

  cmd:
    type: ["null", string]
  
    inputBinding:
      prefix: --cmd 

  java_args:
    type: ["null", string]
    default: -Xmx48g -Xms256m -XX:-UseGCOverheadLimit
    doc: args to pass to java
    inputBinding:
      prefix: --java_args 

  java_temp:
    type: ["null", string]
    doc: java.io.temp_dir, if you want to set it
    inputBinding:
      prefix: --java-temp 

  out:
    type:
    - string
    - type: array
      items: string
  
    doc: An output file created by the walker. Will overwrite contents if file exists
    inputBinding:
      prefix: --out 

  minMappingQuality:
    type: string
    doc: Minimum mapping quality of reads to count towards depth
    inputBinding:
      prefix: --minMappingQuality 

  maxMappingQuality:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Maximum mapping quality of reads to count towards 
    inputBinding:
      prefix: --maxMappingQuality 

  minBaseQuality:
    type: string
    doc: Minimum quality of bases to count towards depth
    inputBinding:
      prefix: --minBaseQuality 

  maxBaseQuality:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Maximum quality of bases to count towards depth
    inputBinding:
      prefix: --maxBaseQuality 

  countType:
    type:
    - "null"
    - type: array
      items: string
  
    doc: How should overlapping reads from the same 
    inputBinding:
      prefix: --countType 

  printBaseCounts:
    type: ["null", boolean]
    default: False
    doc: Add base counts to per-locus output
    inputBinding:
      prefix: --printBaseCounts 

  omitLocusTable:
    type: ["null", boolean]
    default: False
    doc: Do not calculate per-sample per-depth counts of loci
    inputBinding:
      prefix: --omitLocusTable 

  omitIntervalStatistics:
    type: ["null", boolean]
    default: False
    doc: Do not calculate per-interval statistics
    inputBinding:
      prefix: --omitIntervalStatistics 

  omitDepthOutputAtEachBase:
    type: ["null", boolean]
    default: False
    doc: Do not output depth of coverage at each base
    inputBinding:
      prefix: --omitDepthOutputAtEachBase 

  calculateCoverageOverGenes:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Calculate coverage statistics over this list of genes
    inputBinding:
      prefix: --calculateCoverageOverGenes 

  outputFormat:
    type:
    - "null"
    - type: array
      items: string
  
    doc: The format of the output file
    inputBinding:
      prefix: --outputFormat 

  includeRefNSites:
    type: ["null", boolean]
    default: False
    doc: Include sites where the reference is N
    inputBinding:
      prefix: --includeRefNSites 

  printBinEndpointsAndExit:
    type: ["null", boolean]
    default: False
    doc: Print the bin values and exit immediately
    inputBinding:
      prefix: --printBinEndpointsAndExit 

  start:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Starting (left endpoint) for granular binning
    inputBinding:
      prefix: --start 

  stop:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Ending (right endpoint) for granular binning
    inputBinding:
      prefix: --stop 

  nBins:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Number of bins to use for granular binning
    inputBinding:
      prefix: --nBins 

  omitPerSampleStats:
    type: ["null", boolean]
    default: False
    doc: Do not output the summary files per-sample
    inputBinding:
      prefix: --omitPerSampleStats 

  partitionType:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Partition type for depth of coverage
    inputBinding:
      prefix: --partitionType 

  includeDeletions:
    type: ["null", boolean]
    default: False
    doc: Include information on deletions
    inputBinding:
      prefix: --includeDeletions 

  ignoreDeletionSites:
    type: ["null", boolean]
    default: False
    doc: Ignore sites consisting only of deletions
    inputBinding:
      prefix: --ignoreDeletionSites 

  arg_file:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Reads arguments from the specified file
    inputBinding:
      prefix: --arg_file 

  input_file:
    type:
    - File
    - type: array
      items: string
  
    doc: Input file containing sequence data (SAM or BAM)
    inputBinding:
      prefix: --input_file 

  read_buffer_size:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Number of reads per SAM file to buffer in memory
    inputBinding:
      prefix: --read_buffer_size 

  phone_home:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Run reporting mode (NO_ET|AWS| STDOUT)
    inputBinding:
      prefix: --phone_home 

  gatk_key:
    type:
    - "null"
    - type: array
      items: string
  
    doc: GATK key file required to run with -et NO_ET
    inputBinding:
      prefix: --gatk_key 

  tag:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Tag to identify this GATK run as part of a group of runs
    inputBinding:
      prefix: --tag 

  read_filter:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Filters to apply to reads before analysis
    inputBinding:
      prefix: --read_filter 

  intervals:
    type: 
    - string
    - File
  
    doc: One or more genomic intervals over which to operate
    inputBinding:
      prefix: --intervals 

  excludeIntervals:
    type:
    - "null"
    - type: array
      items: string
  
    doc: One or more genomic intervals to exclude from processing
    inputBinding:
      prefix: --excludeIntervals 

  interval_set_rule:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Set merging approach to use for combining interval inputs (UNION|INTERSECTION)
    inputBinding:
      prefix: --interval_set_rule 

  interval_merging:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Interval merging rule for abutting intervals (ALL| OVERLAPPING_ONLY)
    inputBinding:
      prefix: --interval_merging 

  interval_padding:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Amount of padding (in bp) to add to each interval
    inputBinding:
      prefix: --interval_padding 

  reference_sequence:
    type:
    - "null"
    - type: enum
      symbols: ['GRCm38', 'ncbi36', 'mm9', 'GRCh37', 'GRCh38', 'hg18', 'hg19', 'mm10']
  
    inputBinding:
      prefix: --reference_sequence 

  nonDeterministicRandomSeed:
    type: ["null", boolean]
    default: False
    doc: Use a non-deterministic random seed
    inputBinding:
      prefix: --nonDeterministicRandomSeed 

  maxRuntime:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Stop execution cleanly as soon as maxRuntime has been reached
    inputBinding:
      prefix: --maxRuntime 

  maxRuntimeUnits:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Unit of time used by maxRuntime (NANOSECONDS|MICROSECONDS| MILLISECONDS|SECONDS|MINUTES| HOURS|DAYS)
    inputBinding:
      prefix: --maxRuntimeUnits 

  downsampling_type:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Type of read downsampling to employ at a given locus (NONE| ALL_READS|BY_SAMPLE)
    inputBinding:
      prefix: --downsampling_type 

  downsample_to_fraction:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Fraction of reads to downsample to
    inputBinding:
      prefix: --downsample_to_fraction 

  downsample_to_coverage:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Target coverage threshold for downsampling to coverage
    inputBinding:
      prefix: --downsample_to_coverage 

  baq:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Type of BAQ calculation to apply in the engine (OFF| CALCULATE_AS_NECESSARY| RECALCULATE)
    inputBinding:
      prefix: --baq 

  baqGapOpenPenalty:
    type:
    - "null"
    - type: array
      items: string
  
    doc: BAQ gap open penalty
    inputBinding:
      prefix: --baqGapOpenPenalty 

  refactor_NDN_cigar_string:
    type: ["null", boolean]
    default: False
    doc: refactor cigar string with NDN elements to one element
    inputBinding:
      prefix: --refactor_NDN_cigar_string 

  fix_misencoded_quality_scores:
    type: ["null", boolean]
    default: False
    doc: Fix mis-encoded base quality scores
    inputBinding:
      prefix: --fix_misencoded_quality_scores 

  allow_potentially_misencoded_quality_scores:
    type: ["null", boolean]
    default: False
    doc: Ignore warnings about base quality score encoding
    inputBinding:
      prefix: --allow_potentially_misencoded_quality_scores 

  useOriginalQualities:
    type: ["null", boolean]
    default: False
    doc: Use the base quality scores from the OQ tag
    inputBinding:
      prefix: --useOriginalQualities 

  defaultBaseQualities:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Assign a default base quality
    inputBinding:
      prefix: --defaultBaseQualities 

  performanceLog:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Write GATK runtime performance log to this file
    inputBinding:
      prefix: --performanceLog 

  BQSR:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Input covariates table file for on-the-fly base quality score recalibration
    inputBinding:
      prefix: --BQSR 

  disable_indel_quals:
    type: ["null", boolean]
    default: False
    doc: Disable printing of base insertion and deletion tags (with -BQSR)
    inputBinding:
      prefix: --disable_indel_quals 

  emit_original_quals:
    type: ["null", boolean]
    default: False
    doc: Emit the OQ tag with the original base qualities (with -BQSR)
    inputBinding:
      prefix: --emit_original_quals 

  preserve_qscores_less_than:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Don't recalibrate bases with quality scores less than this threshold (with -BQSR)
    inputBinding:
      prefix: --preserve_qscores_less_than 

  globalQScorePrior:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Global Qscore Bayesian prior to use for BQSR
    inputBinding:
      prefix: --globalQScorePrior 

  validation_strictness:
    type:
    - "null"
    - type: array
      items: string
  
    doc: How strict should we be with validation (STRICT|LENIENT| SILENT)
    inputBinding:
      prefix: --validation_strictness 

  remove_program_records:
    type: ["null", boolean]
    default: False
    doc: Remove program records from the SAM header
    inputBinding:
      prefix: --remove_program_records 

  keep_program_records:
    type: ["null", boolean]
    default: False
    doc: Keep program records in the SAM header
    inputBinding:
      prefix: --keep_program_records 

  sample_rename_mapping_file:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Rename sample IDs on-the-fly at runtime using the provided mapping file
    inputBinding:
      prefix: --sample_rename_mapping_file 

  unsafe:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Enable unsafe operations - nothing will be checked at runtime (ALLOW_N_CIGAR_READS| ALLOW_UNINDEXED_BAM| ALLOW_UNSET_BAM_SORT_ORDER| NO_READ_ORDER_VERIFICATION| ALLOW_SEQ_DICT_INCOMPATIBILITY| LENIENT_VCF_PROCESSING|ALL)
    inputBinding:
      prefix: --unsafe 

  sites_only:
    type: ["null", boolean]
    default: False
    doc: Just output sites without genotypes (i.e. only the first 8 columns of the VCF)
    inputBinding:
      prefix: --sites_only 

  never_trim_vcf_format_field:
    type: ["null", boolean]
    default: False
    doc: Always output all the records in VCF FORMAT fields, even if some are missing
    inputBinding:
      prefix: --never_trim_vcf_format_field 

  bam_compression:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Compression level to use for writing BAM files (0 - 9, higher is more compressed)
    inputBinding:
      prefix: --bam_compression 

  simplifyBAM:
    type: ["null", boolean]
    default: False
    doc: If provided, output BAM files will be simplified to include just key reads for downstream variation discovery analyses (removing duplicates, PF-, non-primary reads), as well stripping all extended tags from the kept reads except the read group identifier
    inputBinding:
      prefix: --simplifyBAM 

  disable_bam_indexing:
    type: ["null", boolean]
    default: False
    doc: Turn off on-the-fly creation of 
    inputBinding:
      prefix: --disable_bam_indexing 

  generate_md5:
    type: ["null", boolean]
    default: False
    doc: Enable on-the-fly creation of 
    inputBinding:
      prefix: --generate_md5 

  num_threads:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Number of data threads to allocate to this analysis
    inputBinding:
      prefix: --num_threads 

  num_cpu_threads_per_data_thread:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Number of CPU threads to allocate per data thread
    inputBinding:
      prefix: --num_cpu_threads_per_data_thread 

  monitorThreadEfficiency:
    type: ["null", boolean]
    default: False
    doc: Enable threading efficiency monitoring
    inputBinding:
      prefix: --monitorThreadEfficiency 

  num_bam_file_handles:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Total number of BAM file handles to keep open simultaneously
    inputBinding:
      prefix: --num_bam_file_handles 

  read_group_black_list:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Exclude read groups based on tags
    inputBinding:
      prefix: --read_group_black_list 

  pedigree:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Pedigree files for samples
    inputBinding:
      prefix: --pedigree 

  pedigreeString:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Pedigree string for samples
    inputBinding:
      prefix: --pedigreeString 

  pedigreeValidationType:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Validation strictness for pedigree information (STRICT| SILENT)
    inputBinding:
      prefix: --pedigreeValidationType 

  variant_index_type:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Type of IndexCreator to use for VCF/BCF indices (DYNAMIC_SEEK| DYNAMIC_SIZE|LINEAR|INTERVAL)
    inputBinding:
      prefix: --variant_index_type 

  variant_index_parameter:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Parameter to pass to the VCF/BCF IndexCreator
    inputBinding:
      prefix: --variant_index_parameter 

  logging_level:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Set the minimum level of logging
    inputBinding:
      prefix: --logging_level 

  log_to_file:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Set the logging location
    inputBinding:
      prefix: --log_to_file 

  summaryCoverageThreshold:
    type:
    - "null"
    - type: array
      items: string
  
    doc: Coverage threshold (in percent) for summarizing statistics
    inputBinding:
      prefix: --summaryCoverageThreshold 

  filter_reads_with_N_cigar:
    type: ["null", boolean]
    default: False
    doc: filter out reads with CIGAR containing the N operator, instead of stop processing and report an error.
    inputBinding:
      prefix: --filter_reads_with_N_cigar 

  filter_mismatching_base_and_quals:
    type: ["null", boolean]
    default: False
    doc: if a read has mismatching number of bases and base qualities, filter out the read instead of blowing up.
    inputBinding:
      prefix: --filter_mismatching_base_and_quals 

  filter_bases_not_stored:
    type: ["null", boolean]
    default: False
    doc: if a read has no stored bases (i.e. a '*'), filter out the read instead of blowing up.
    inputBinding:
      prefix: --filter_bases_not_stored 

  stderr:
    type: ["null",string]
    doc: log stderr to file
    inputBinding:
      prefix: --stderr 

  stdout:
    type: ["null", string]
    doc: log stdout to file
    inputBinding:
      prefix: --stdout 


outputs:
  out_file:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.out)
            return inputs.out;
          return null;
        }
