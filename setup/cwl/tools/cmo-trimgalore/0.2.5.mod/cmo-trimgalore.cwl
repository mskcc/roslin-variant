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
  doap:revision: 0.2.5.mod
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

arguments:
- valueFrom: "0.2.5.mod"
  prefix: --version
  position: 0

requirements:
- class: InlineJavascriptRequirement
  expressionLib:
  - var getBaseName = function(inputFile) { return inputFile.basename; };
- class: ResourceRequirement
  ramMin: 12000
  coresMin: 1


doc: |
  None

inputs:

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
    doc: Adapter sequence to be trimmed. If not specified explicitely, the first 13
      bp of the Illumina adapter 'AGATCGGAAGAGC' will be used by default.
    inputBinding:
      prefix: --adapter

  adapter2:
    type: ['null', string]
    doc: Optional adapter sequence to be trimmed off read 2 of paired-end files. This
      option requires '--paired' to be specified as well.
    inputBinding:
      prefix: --adapter2

  stringency:
    type: ['null', string]
    doc: Overlap with adapter sequence required to trim a sequence. Defaults to a
      very stringent setting of '1', i.e. even a single bp of overlapping sequence
      will be trimmed of the 3' end of any read.-e <ERROR RATE> Maximum allowed error
      rate (no. of errors divided by the length of the matching region) (default -
      0.1)
    inputBinding:
      prefix: --stringency

  gzip:
    type: ['null', boolean]
    default: false
    doc: Compress the output file with gzip. If the input files are gzip-compressed
      the output files will be automatically gzip compressed as well.
    inputBinding:
      prefix: --gzip

  length:
    type: ['null', string]
    doc: Discard reads that became shorter than length INT because of either quality
      or adapter trimming. A value of '0' effectively disables this behaviour. Default
      - 20 bp. For paired-end files, both reads of a read-pair need to be longer than
      <INT> bp to be printed out to validated paired-end files (see option --paired).
      If only one read became too short there is the possibility of keeping such unpaired
      single-end reads (see --retain_unpaired). Default pair-cutoff - 20 bp.
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
    doc: If specified any output to STDOUT or STDERR will be suppressed.RRBS-specific
      options (MspI digested material) -
    inputBinding:
      prefix: --suppress_warn

  rrbs:
    type: ['null', boolean]
    default: false
    doc: Specifies that the input file was an MspI digested RRBS sample (recognition
      site - CCGG). Sequences which were adapter-trimmed will have a further 2 bp
      removed from their 3' end. This is to avoid that the filled-in C close to the
      second MspI site in a sequence is used for methylation calls. Sequences which
      were merely trimmed because of poor quality will not be shortened further.
    inputBinding:
      prefix: --rrbs

  non_directional:
    type: ['null', boolean]
    default: false
    doc: Selecting this option for non-directional RRBS libraries will screen quality-trimmed
      sequences for 'CAA' or 'CGA' at the start of the read and, if found, removes
      the first two basepairs. Like with the option '--rrbs' this avoids using cytosine
      positions that were filled-in during the end-repair step. '--non_directional'
      requires '--rrbs' to be specified as well.
    inputBinding:
      prefix: --non_directional

  keep:
    type: ['null', boolean]
    default: false
    doc: Keep the quality trimmed intermediate file. Default - off, which means the
      temporary file is being deleted after adapter trimming. Only has an effect for
      RRBS samples since other FastQ files are not trimmed for poor qualities separately.Note
      for RRBS using MseI -If your DNA material was digested with MseI (recognition
      motif - TTAA) instead of MspI it is NOT necessaryto specify --rrbs or --non_directional
      since virtually all reads should start with the sequence'TAA', and this holds
      true for both directional and non-directional libraries. As the end-repair of
      'TAA'restricted sites does not involve any cytosines it does not need to be
      treated especially. Instead, simplyrun Trim Galore! in the standard (i.e. non-RRBS)
      mode.Paired-end specific options -
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
      read).
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
      Default - 35 bp.Last modified on 18 Oct 2012.
    inputBinding:
      prefix: --length_2

  fastq1:
    type: File


    inputBinding:
      position: 1

  fastq2:
    type: File
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
            return getBaseName(inputs.fastq1).replace(".fastq.gz", "_cl.fastq.gz");
          return null;
        }
  clfastq2:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.paired && inputs.fastq2)
            return getBaseName(inputs.fastq2).replace(".fastq.gz", "_cl.fastq.gz");
          return null;
        }
  clstats1:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.paired && inputs.fastq1)
            return getBaseName(inputs.fastq1).replace(".fastq.gz", "_cl.stats");
          return null;
        }

  clstats2:
    type: File
    outputBinding:
      glob: |-
        ${
          if (inputs.paired && inputs.fastq2)
            return getBaseName(inputs.fastq2).replace(".fastq.gz", "_cl.stats");
          return null;
        }
