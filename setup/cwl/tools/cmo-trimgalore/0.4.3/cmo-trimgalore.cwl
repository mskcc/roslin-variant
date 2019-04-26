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
  doap:name: cmo-trimgalore
  doap:revision: 0.4.3
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
# To generate again: $ cmo_trimgalore -o FILENAME --generate_cwl_tool
# Help: $ cmo_trimgalore  --help_arg2cwl

cwlVersion: v1.0

class: CommandLineTool
baseCommand: [cmo_trimgalore]
id: cmo-trimgalore

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 12000
    coresMin: 1

doc: |
  None

inputs:
  version:
    type:
    - 'null'
    - type: enum
      symbols: [default]
    default: default

    inputBinding:
      prefix: --version

  quality:
    type: ['null', string]
    doc: Trim low-quality ends from reads in addition to adapter removal. For RRBS
      samples, quality trimming will be performed first, and adapter trimming is carried
      in a second round. Other files are quality and adapter trimmed in a single pass.
      The algorithm is the same as the one used by BWA (Subtract INT from all qualities;
      compute partial sums from all indices to the end of the sequence; cut sequence
      at the index at which the sum is minimal). Default Phred score - 20.
    inputBinding:
      prefix: --quality

    default: '1'
  phred33:
    type: ['null', boolean]
    default: false
    doc: Instructs Cutadapt to use ASCII+33 quality scores as Phred scores (Sanger/Illumina
      1.9+ encoding) for quality trimming. Default - ON.
    inputBinding:
      prefix: --phred33

  phred64:
    type: ['null', boolean]
    default: false
    doc: Instructs Cutadapt to use ASCII+64 quality scores as Phred scores (Illumina
      1.5 encoding) for quality trimming.
    inputBinding:
      prefix: --phred64

  fastqc:
    type: ['null', boolean]
    default: false
    doc: Run FastQC in the default mode on the FastQ file once trimming is complete.--fastqc_args
      "<ARGS>" Passes extra arguments to FastQC. If more than one argument is to be
      passed to FastQC they must be in the form "arg1 arg2 etc.". An example would
      be - --fastqc_args "--nogroup --outdir /home/". Passing extra arguments will
      automatically invoke FastQC, so --fastqc does not have to be specified separately.
    inputBinding:
      prefix: --fastqc

  adapter:
    type: ['null', string]
    doc: Adapter sequence to be trimmed. If not specified explicitly, Trim Galore
      will try to auto-detect whether the Illumina universal, Nextera transposase
      or Illumina small RNA adapter sequence was used. Also see '--illumina', '--nextera'
      and '--small_rna'. If no adapter can be detected within the first 1 million
      sequences of the first file specified Trim Galore defaults to '--illumina'.
    inputBinding:
      prefix: --adapter

  adapter2:
    type: ['null', string]
    doc: Optional adapter sequence to be trimmed off read 2 of paired-end files. This
      option requires '--paired' to be specified as well. If the libraries to be trimmed
      are smallRNA then a2 will be set to the Illumina small RNA 5' adapter automatically
      (GATCGTCGGACT).
    inputBinding:
      prefix: --adapter2

  illumina:
    type: ['null', boolean]
    default: false
    doc: Adapter sequence to be trimmed is the first 13bp of the Illumina universal
      adapter 'AGATCGGAAGAGC' instead of the default auto-detection of adapter sequence.
    inputBinding:
      prefix: --illumina

  nextera:
    type: ['null', boolean]
    default: false
    doc: Adapter sequence to be trimmed is the first 12bp of the Nextera adapter 'CTGTCTCTTATA'
      instead of the default auto-detection of adapter sequence.
    inputBinding:
      prefix: --nextera

  small_rna:
    type: ['null', boolean]
    default: false
    doc: Adapter sequence to be trimmed is the first 12bp of the Illumina Small RNA
      3' Adapter 'TGGAATTCTCGG' instead of the default auto-detection of adapter sequence.
      Selecting to trim smallRNA adapters will also lower the --length value to 18bp.
      If the smallRNA libraries are paired-end then a2 will be set to the Illumina
      small RNA 5' adapter automatically (GATCGTCGGACT) unless -a 2 had been defined
      explicitly.
    inputBinding:
      prefix: --small_rna

  max_length:
    type: ['null', string]
    doc: Discard reads that are longer than <INT> bp after trimming. This is only
      advised for smallRNA sequencing to remove non-small RNA sequences.
    inputBinding:
      prefix: --max_length

  stringency:
    type: ['null', string]
    doc: Overlap with adapter sequence required to trim a sequence. Defaults to a
      very stringent setting of 1, i.e. even a single bp of overlapping sequence will
      be trimmed off from the 3' end of any read.-e <ERROR RATE> Maximum allowed error
      rate (no. of errors divided by the length of the matching region) (default -
      0.1)
    inputBinding:
      prefix: --stringency

  gzip:
    type: ['null', boolean]
    default: true
    doc: Compress the output file with GZIP. If the input files are GZIP-compressed
      the output files will automatically be GZIP compressed as well. As of v0.2.8
      the compression will take place on the fly.
    inputBinding:
      prefix: --gzip

  dont_gzip:
    type: ['null', boolean]
    default: false
    doc: Output files won't be compressed with GZIP. This option overrides --gzip.
    inputBinding:
      prefix: --dont_gzip

  length:
    type: ['null', string]
    doc: Discard reads that became shorter than length INT because of either quality
      or adapter trimming. A value of '0' effectively disables this behaviour. Default
      - 20 bp. For paired-end files, both reads of a read-pair need to be longer than
      <INT> bp to be printed out to validated paired-end files (see option --paired).
      If only one read became too short there is the possibility of keeping such unpaired
      single-end reads (see --retain_unpaired). Default pair-cutoff - 20 bp.--max_n
      COUNT The total number of Ns (as integer) a read may contain before it will
      be removed altogether. In a paired-end setting, either read exceeding this limit
      will result in the entire pair being removed from the trimmed output files.--trim-n
      Removes Ns from either side of the read. This option does currently not work
      in RRBS mode.
    inputBinding:
      prefix: --length

    default: '25'
  output_dir:
    type: ['null', string]
    doc: If specified all output will be written to this directory instead of the
      current directory.
    inputBinding:
      prefix: --output_dir

  no_report_file:
    type: ['null', boolean]
    default: false
    doc: If specified no report file will be generated.
    inputBinding:
      prefix: --no_report_file

  suppress_warn:
    type: ['null', boolean]
    default: true
    doc: If specified any output to STDOUT or STDERR will be suppressed.
    inputBinding:
      prefix: --suppress_warn

  clip_R1:
    type: ['null', boolean]
    default: false
    doc: Instructs Trim Galore to remove <int> bp from the 5' end of read 1 (or single-end
      reads). This may be useful if the qualities were very poor, or if there is some
      sort of unwanted bias at the 5' end. Default - OFF.
    inputBinding:
      prefix: --clip_R1

  clip_R2:
    type: ['null', boolean]
    default: false
    doc: Instructs Trim Galore to remove <int> bp from the 5' end of read 2 (paired-end
      reads only). This may be useful if the qualities were very poor, or if there
      is some sort of unwanted bias at the 5' end. For paired-end BS-Seq, it is recommended
      to remove the first few bp because the end-repair reaction may introduce a bias
      towards low methylation. Please refer to the M-bias plot section in the Bismark
      User Guide for some examples. Default - OFF.
    inputBinding:
      prefix: --clip_R2

  three_prime_clip_R1:
    type: ['null', boolean]
    default: false
    doc: Instructs Trim Galore to remove <int> bp from the 3' end of read 1 (or single-end
      reads) AFTER adapter/quality trimming has been performed. This may remove some
      unwanted bias from the 3' end that is not directly related to adapter sequence
      or basecall quality. Default - OFF.
    inputBinding:
      prefix: --three_prime_clip_R1

  three_prime_clip_R2:
    type: ['null', boolean]
    default: false
    doc: Instructs Trim Galore to remove <int> bp from the 3' end of read 2 AFTER
      adapter/quality trimming has been performed. This may remove some unwanted bias
      from the 3' end that is not directly related to adapter sequence or basecall
      quality. Default - OFF.--path_to_cutadapt </path/to/cutadapt> You may use this
      option to specify a path to the Cutadapt executable, e.g. /my/home/cutadapt-1.7.1/bin/cutadapt.
      Else it is assumed that Cutadapt is in the PATH.RRBS-specific options (MspI
      digested material) -
    inputBinding:
      prefix: --three_prime_clip_R2

  rrbs:
    type: ['null', boolean]
    default: false
    doc: Specifies that the input file was an MspI digested RRBS sample (recognition
      site - CCGG). Single-end or Read 1 sequences (paired-end) which were adapter-trimmed
      will have a further 2 bp removed from their 3' end. Sequences which were merely
      trimmed because of poor quality will not be shortened further. Read 2 of paired-end
      libraries will in addition have the first 2 bp removed from the 5' end (by setting
      '--clip_r2 2'). This is to avoid using artificial methylation calls from the
      filled-in cytosine positions close to the 3' MspI site in sequenced fragments.
      This option is not recommended for users of the NuGEN ovation RRBS System 1-16
      kit (see below).
    inputBinding:
      prefix: --rrbs

  non_directional:
    type: ['null', boolean]
    default: false
    doc: Selecting this option for non-directional RRBS libraries will screen quality-trimmed
      sequences for 'CAA' or 'CGA' at the start of the read and, if found, removes
      the first two basepairs. Like with the option '--rrbs' this avoids using cytosine
      positions that were filled-in during the end-repair step. '--non_directional'
      requires '--rrbs' to be specified as well. Note that this option does not set
      '--clip_r2 2' in paired-end mode.
    inputBinding:
      prefix: --non_directional

  keep:
    type: ['null', boolean]
    default: false
    doc: Keep the quality trimmed intermediate file. Default - off, which means the
      temporary file is being deleted after adapter trimming. Only has an effect for
      RRBS samples since other FastQ files are not trimmed for poor qualities separately.Note
      for RRBS using the NuGEN Ovation RRBS System 1-16 kit -Owing to the fact that
      the NuGEN Ovation kit attaches a varying number of nucleotides (0-3) after each
      MspIsite Trim Galore should be run WITHOUT the option --rrbs. This trimming
      is accomplished in a subsequent diversity trimming step afterwards (see their
      manual).Note for RRBS using MseI -If your DNA material was digested with MseI
      (recognition motif - TTAA) instead of MspI it is NOT necessaryto specify --rrbs
      or --non_directional since virtually all reads should start with the sequence'TAA',
      and this holds true for both directional and non-directional libraries. As the
      end-repair of 'TAA'restricted sites does not involve any cytosines it does not
      need to be treated especially. Instead, simplyrun Trim Galore! in the standard
      (i.e. non-RRBS) mode.Paired-end specific options -
    inputBinding:
      prefix: --keep

  paired:
    type: ['null', boolean]
    default: true
    doc: This option performs length trimming of quality/adapter/RRBS trimmed reads
      for paired-end files. To pass the validation test, both sequences of a sequence
      pair are required to have a certain minimum length which is governed by the
      option --length (see above). If only one read passes this length threshold the
      other read can be rescued (see option --retain_unpaired). Using this option
      lets you discard too short read pairs without disturbing the sequence-by-sequence
      order of FastQ files which is required by many aligners. Trim Galore! expects
      paired-end files to be supplied in a pairwise fashion, e.g. file1_1.fq file1_2.fq
      SRR2_1.fq.gz SRR2_2.fq.gz ... .
    inputBinding:
      prefix: --paired

  trim1:
    type: ['null', boolean]
    default: false
    doc: Trims 1 bp off every read from its 3' end. This may be needed for FastQ files
      that are to be aligned as paired-end data with Bowtie. This is because Bowtie
      (1) regards alignments like this - R1 ---------------------------> or this -
      -----------------------> R1 R2 <--------------------------- <-----------------
      R2 as invalid (whenever a start/end coordinate is contained within the other
      read). NOTE - If you are planning to use Bowtie2, BWA etc. you don't need to
      specify this option.
    inputBinding:
      prefix: --trim1

  retain_unpaired:
    type: ['null', boolean]
    default: false
    doc: If only one of the two paired-end reads became too short, the longer read
      will be written to either '.unpaired_1.fq' or '.unpaired_2.fq' output files.
      The length cutoff for unpaired single-end reads is governed by the parameters
      -r1/--length_1 and -r2/--length_2. Default - OFF.
    inputBinding:
      prefix: --retain_unpaired

  length_1:
    type: ['null', string]
    doc: Unpaired single-end read length cutoff needed for read 1 to be written to
      '.unpaired_1.fq' output file. These reads may be mapped in single-end mode.
      Default - 35 bp.
    inputBinding:
      prefix: --length_1

  length_2:
    type: ['null', string]
    doc: Unpaired single-end read length cutoff needed for read 2 to be written to
      '.unpaired_2.fq' output file. These reads may be mapped in single-end mode.
      Default - 35 bp.Last modified on 07 December 2016.
    inputBinding:
      prefix: --length_2

  fastq1:
    type: 


    - string
    - File
    inputBinding:
      position: 1

  fastq2:
    type:
    - string
    - File
    inputBinding:
      position: 2

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
  clfastq1:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.paired && inputs.fastq1)
            return inputs.fastq1.split('/').slice(-1)[0].split('.').slice(0)[0] + '_val_1.fq.gz';
          else
            return null;
        }

  clfastq2:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.paired && inputs.fastq1)
            return inputs.fastq2.split('/').slice(-1)[0].split('.').slice(0)[0] + '_val_2.fq.gz';
          else
            return null;
        }

  clstats1:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.paired && inputs.fastq1)
            return inputs.fastq1.split('/').slice(-1)[0] + '_trimming_report.txt';
          else
            return null;
        }

  clstats2:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.paired && inputs.fastq2)
            return inputs.fastq2.split('/').slice(-1)[0] + '_trimming_report.txt';
          else
            return null;
        }

