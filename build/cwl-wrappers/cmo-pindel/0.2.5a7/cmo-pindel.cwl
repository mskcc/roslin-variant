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
  doap:name: cmo-pindel
  doap:revision: 0.2.5a7
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
# To generate again: $ cmo_pindel -o FILENAME --generate_cwl_tool
# Help: $ cmo_pindel  --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- cmo_pindel
- --version
- 0.2.5a7

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 10
    coresMin: 4 

doc: |
  None

inputs:
  pindel_file:
    type: ['null', string]
    doc: the Pindel input file; either this, a pindel configuration file (consisting
      of multiple pindel filenames) or a bam configuration file is required
    inputBinding:
      prefix: --pindel-file

  output_prefix:
    type: ['null', string]
    doc: Output prefix; Optional parameters -
    inputBinding:
      prefix: --output-prefix

  pindel_config_file:
    type: ['null', string]
    doc: the pindel config file, containing the names of all Pindel files that need
      to be sampled; either this, a bam config file or a pindel input file is required.
      Per line - path and file name of pindel input. Example - /data/tumour.txt
    inputBinding:
      prefix: --pindel-config-file

  chromosome:
    type: ['null', string]
    doc: Which chr/fragment. Pindel will process reads for one chromosome each time.
      ChrName must be the same as in reference sequence and in read file. '-c ALL'
      will make Pindel loop over all chromosomes. The search for indels and SVs can
      also be limited to a specific region; -c 20 -10,000,000 will only look for indels
      and SVs after position 10,000,000 = [10M, end], -c 20 -5,000,000-15,000,000
      will report indels in the range between and including the bases at position
      5,000,000 and 15,000,000 = [5M, 15M]. (default ALL)
    inputBinding:
      prefix: --chromosome

  RP:
    type: ['null', boolean]
    default: false
    doc: search for discordant read-pair to improve sensitivity (default true)
    inputBinding:
      prefix: --RP

  min_distance_to_the_end:
    type: ['null', string]
    doc: the minimum number of bases required to match reference (default 8).
    inputBinding:
      prefix: --min_distance_to_the_end

  number_of_threads:
    type: ['null', string]
    doc: the number of threads Pindel will use (default 1).
    inputBinding:
      prefix: --number_of_threads

    default: '5'
  max_range_index:
    type: ['null', string]
    doc: the maximum size of structural variations to be detected; the higher this
      number, the greater the number of SVs reported, but the computational cost and
      memory requirements increase, as does the rate of false positives. 1=128, 2=512,
      3=2,048, 4=8,092, 5=32,368, 6=129,472, 7=517,888, 8=2,071,552, 9=8,286,208.
      (maximum 9, default 4)
    inputBinding:
      prefix: --max_range_index

  window_size:
    type: ['null', string]
    doc: for saving RAM, divides the reference in bins of X million bases and only
      analyzes the reads that belong in the current bin, (default 5 (=5 million))
    inputBinding:
      prefix: --window_size

  sequencing_error_rate:
    type: ['null', string]
    doc: the expected fraction of sequencing errors (default 0.01)
    inputBinding:
      prefix: --sequencing_error_rate

  sensitivity:
    type: ['null', string]
    doc: Pindel only reports reads if they can be fit around an event within a certain
      number of mismatches. If the fraction of sequencing errors is 0.01, (so we'd
      expect a total error rate of 0.011 since on average 1 in 1000 bases is a SNP)
      and pindel calls a deletion, but there are 4 mismatched bases in the new fit
      of the pindel read (100 bases) to the reference genome, Pindel would calculate
      that with an error rate of 0.01 (=0.011 including SNPs) the chance that there
      are 0, 1 or 2 mismatched bases in the reference genome is 90%%. Setting -E to
      .90 (=90%%) will thereforethrow away all reads with 3 or more mismatches, even
      though that means that you throw away 1 in 10 valid reads. Increasing this parameter
      to say 0.99 will increase the sensitivity of pindel though you may get more
      false positives, decreasing the parameter ensures you only get very good matches
      but pindel may not find as many events. (default 0.95)
    inputBinding:
      prefix: --sensitivity

  maximum_allowed_mismatch_rate:
    type: ['null', string]
    doc: Only reads with more than this fraction of mismatches than the reference
      genome will be considered as harboring potential SVs. (default 0.02)
    inputBinding:
      prefix: --maximum_allowed_mismatch_rate

  NM:
    type: ['null', string]
    doc: the minimum number of edit distance between reads and reference genome (default
      2). reads at least NM edit distance (>= NM) will be realigned
    inputBinding:
      prefix: --NM

  report_inversions:
    type: ['null', boolean]
    default: false
    doc: report inversions (default true)
    inputBinding:
      prefix: --report_inversions

  report_duplications:
    type: ['null', boolean]
    default: false
    doc: report tandem duplications (default true)
    inputBinding:
      prefix: --report_duplications

  report_long_insertions:
    type: ['null', boolean]
    default: false
    doc: report insertions of which the full sequence cannot be deduced because of
      their length (default false)
    inputBinding:
      prefix: --report_long_insertions

  report_breakpoints:
    type: ['null', boolean]
    default: false
    doc: report breakpoints (default false)
    inputBinding:
      prefix: --report_breakpoints

  report_close_mapped_reads:
    type: ['null', boolean]
    default: false
    doc: report reads of which only one end (the one closest to the mapped read of
      the paired-end read) could be mapped. (default false)
    inputBinding:
      prefix: --report_close_mapped_reads

  report_only_close_mapped_reads:
    type: ['null', boolean]
    default: false
    doc: do not search for SVs, only report reads of which only one end (the one closest
      to the mapped read of the paired-end read) could be mapped (the output file
      can then be used as an input file for another run of pindel, which may save
      size if you need to transfer files). (default false)
    inputBinding:
      prefix: --report_only_close_mapped_reads

  report_interchromosomal_events:
    type: ['null', boolean]
    default: false
    doc: search for interchromosomal events. Note - will require the computer to have
      at least 4 GB of memory (default true)
    inputBinding:
      prefix: --report_interchromosomal_events

  IndelCorrection:
    type: ['null', boolean]
    default: false
    doc: search for consensus indels to corret contigs (default false)
    inputBinding:
      prefix: --IndelCorrection

  NormalSamples:
    type: ['null', boolean]
    default: false
    doc: Turn on germline filtering, less sensistive and you may miss somatic calls
      (default false)
    inputBinding:
      prefix: --NormalSamples

  breakdancer:
    type: ['null', string]
    doc: Pindel is able to use calls from other SV methods such as BreakDancer to
      further increase sensitivity and specificity. BreakDancer result or calls from
      any methods must in the format - ChrA LocA stringA ChrB LocB stringB other
    inputBinding:
      prefix: --breakdancer

  include:
    type:
    - 'null'
    - string
    - File
    doc: If you want Pindel to process a set of regions, please provide a bed file
      here - chr start end
    inputBinding:
      prefix: --include

  exclude:
    type:
    - 'null'
    - string
    - File
    doc: If you want Pindel to skip a set of regions, please provide a bed file here
      - chr start end
    inputBinding:
      prefix: --exclude

  additional_mismatch:
    type: ['null', string]
    doc: Pindel will only map part of a read to the reference genome if there are
      no other candidate positions with no more than the specified number of mismatches
      position. The bigger the value, the more accurate but less sensitive. (minimum
      value 1, default value 1)
    inputBinding:
      prefix: --additional_mismatch

  min_perfect_match_around_BP:
    type: ['null', string]
    doc: at the point where the read is split into two, there should at least be this
      number of perfectly matching bases between read and reference (default value
      3)
    inputBinding:
      prefix: --min_perfect_match_around_BP

  min_num_matched_bases:
    type: ['null', string]
    doc: only consider reads as evidence if they map with more than X bases to the
      reference. (default 30)
    inputBinding:
      prefix: --min_num_matched_bases

  balance_cutoff:
    type: ['null', string]
    doc: the number of bases of a SV above which a more stringent filter is applied
      which demands that both sides of the SV are mapped with sufficiently long strings
      of bases (default 0)
    inputBinding:
      prefix: --balance_cutoff

  anchor_quality:
    type: ['null', string]
    doc: the minimal mapping quality of the reads Pindel uses as anchor If you only
      need high confident calls, set to 30 or higher(default 0)
    inputBinding:
      prefix: --anchor_quality

  minimum_support_for_event:
    type: ['null', string]
    doc: Pindel only calls events which have this number or more supporting reads
      (default 3)
    inputBinding:
      prefix: --minimum_support_for_event

  input_SV_Calls_for_assembly:
    type: ['null', string]
    doc: A filename of a list of SV calls for assembling breakpoints Types - DEL,
      INS, DUP, INV, CTX and ITX File format - Type chrA posA Confidence_Range_A chrB
      posB Confidence_Range_B Example - DEL chr1 10000 50 chr2 20000 100
    inputBinding:
      prefix: --input_SV_Calls_for_assembly

  genotyping:
    type: ['null', string]
    doc: gentype variants if -i is also used.
    inputBinding:
      prefix: --genotyping

  output_of_breakdancer_events:
    type: ['null', string]
    doc: If breakdancer input is used, you can specify a filename here to write the
      confirmed breakdancer events with their exact breakpoints to The list of BreakDancer
      calls with Pindel support information. Format - chr Loc_left Loc_right size
      type index. For example, "1 72766323 72811840 45516 D 11970" means the deletion
      event chr1 -72766323-72811840 of size 45516 is reported as an event with index
      11970 in Pindel report of deletion.
    inputBinding:
      prefix: --output_of_breakdancer_events

  name_of_logfile:
    type: ['null', string]
    doc: Specifies a file to write Pindel's log to (default - no logfile, log is written
      to the screen/stdout)
    inputBinding:
      prefix: --name_of_logfile

  Ploidy:
    type: ['null', string]
    doc: a file with Ploidy information per chr for genotype. per line - ChrName Ploidy.
      For example, chr1 2
    inputBinding:
      prefix: --Ploidy

  detect_DD:
    type: ['null', boolean]
    default: false
    doc: Flag indicating whether to detect dispersed duplications. (default - false)
    inputBinding:
      prefix: --detect_DD

  DD_REPORT_DUPLICATION_READS:
    type: ['null', boolean]
    default: false
    doc: Report discordant sequences and positions for mates of reads mapping inside
      dispersed duplications. (default - false)
    inputBinding:
      prefix: --DD_REPORT_DUPLICATION_READS

  fasta:
    type:
    - 'null'
    - type: enum
      symbols: [GRCm38, hg19, ncbi36, mm9, GRCh37, mm10, hg18, GRCh38]
    default: GRCh37

    inputBinding:
      prefix: --fasta

  sample_names:
    type:
    - 'null'
    - type: array
      items: string
    inputBinding:
      prefix: --sample_names
      itemSeparator: ' '
      separate: true
    doc: one line of config file per specification will autogenerate config on fly.
  bams:
    type:
    - 'null'
    - type: array
      items: File
    inputBinding:
      prefix: --bam
      itemSeparator: ' '
      separate: true
    secondaryFiles: [.bai]
    doc: cwltool doesn't copy file inputs if thy dont have input binding it seems...idk.
  vcf:
    type: ['null', string]
    doc: supply a vcf filename to run pindel2vcf automatically
    inputBinding:
      prefix: --vcf


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
