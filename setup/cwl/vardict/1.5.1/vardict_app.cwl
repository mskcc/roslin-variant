$namespaces:
  dct: http://purl.org/dc/terms/
  doap: http://usefulinc.com/ns/doap#
  foaf: http://xmlns.com/foaf/0.1/
$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#
arguments:
- position: 1
  prefix: -b
  valueFrom: "${\n    return inputs.b.path + \"|\" + inputs.b2.path;\n}"
- position: 0
  prefix: -N
  valueFrom: "${\n    if (inputs.N2)\n        return [inputs.N, inputs.N2];\n    else\n\
    \        return inputs.N;\n}"
baseCommand:
- /usr/bin/vardict/bin/VarDict
class: CommandLineTool
cwlVersion: v1.0
dct:contributor:
- class: foaf:Organization
  foaf:member:
  - class: foaf:Person
    foaf:mbox: mailto:ivkovics@mskcc.org
    foaf:name: Sinisa Ivkovic,
  foaf:name: MSKCC
dct:creator:
- class: foaf:Organization
  foaf:member:
  - class: foaf:Person
    foaf:mbox: mailto:ivkovics@mskcc.org
    foaf:name: Sinisa Ivkovic,
  foaf:name: MSKCC
doap:release:
- class: doap:Version
  doap:name: Vardict
  doap:revision: 1.5.1
- class: doap:Version
  doap:name: MSK-App
  doap:revision: 1.0.0
doc: 'None

  '
id: cmo_vardict
inputs:
- doc: The minimum
  id: B
  inputBinding:
    position: 0
    prefix: -B
  type: int?
- default: true
  doc: Indicate the chromosome names are just numbers, such as 1, 2, not chr1, chr2
  id: C
  inputBinding:
    position: 0
    prefix: -C
  type: boolean?
- default: false
  doc: Debug mode. Will print some error messages and append full genotype at the
    end.
  id: D
  inputBinding:
    position: 0
    prefix: -D
  type: boolean?
- default: '3'
  doc: The column for region end, e.g. gene end
  id: E
  inputBinding:
    position: 0
    prefix: -E
  type: string?
- doc: The hexical to filter reads using samtools. Default - 0x500 (filter 2nd alignments
    and duplicates). Use -F 0 to turn it off.
  id: F
  inputBinding:
    position: 0
    prefix: -F
  type: string?
- id: G
  inputBinding:
    position: 0
    prefix: -G
  secondaryFiles:
  - .fai
  type: File?
- default: false
  doc: Print this help page
  id: H
  inputBinding:
    position: 0
    prefix: -H
  type: boolean?
- doc: The indel size. Default - 120bp
  id: I
  inputBinding:
    position: 0
    prefix: -I
  type: string?
- doc: The minimum matches for a read to be considered. If, after soft-clipping, the
    matched bp is less than INT, then the read is discarded. It's meant for PCR based
    targeted sequencing where there's no insert and the matching is only the primers.
    Default - 0, or no filtering
  id: M
  inputBinding:
    position: 0
    prefix: -M
  type: string?
- doc: Tumor Sample Name
  id: N
  type: string?
- doc: Normal Sample Name
  id: N2
  type: string?
- doc: The reads should have at least mean MapQ to be considered a valid variant.
    Default - no filtering
  id: O
  inputBinding:
    position: 0
    prefix: -O
  type: string?
- doc: The read position filter. If the mean variants position is less that specified,
    it's considered false positive. Default - 5
  id: P
  inputBinding:
    position: 0
    prefix: -P
  type: string?
- default: '20'
  doc: If set, reads with mapping quality less than INT will be filtered and ignored
  id: Q
  inputBinding:
    position: 0
    prefix: -Q
  type: string?
- doc: The region of interest. In the format of chr -start-end. If end is omitted,
    then a single position. No BED is needed.
  id: R
  inputBinding:
    position: 0
    prefix: -R
  type: string?
- default: '2'
  doc: The column for region start, e.g. gene start
  id: S
  inputBinding:
    position: 0
    prefix: -S
  type: string?
- doc: Trim bases after [INT] bases in the reads
  id: T
  inputBinding:
    position: 0
    prefix: -T
  type: string?
- doc: The lowest frequency in normal sample allowed for a putative somatic mutations.
    Default to 0.05
  id: V
  inputBinding:
    position: 0
    prefix: -V
  type: string?
- doc: How strict to be when reading a SAM or BAM. STRICT - throw an exception if
    something looks wrong. LENIENT - Emit warnings but keep going if possible. SILENT
    - Like LENIENT, only don't emit warning messages. Default - LENIENT
  id: VS
  inputBinding:
    position: 0
    prefix: -VS
  type: string?
- default: '5'
  doc: Extension of bp to look for mismatches after insersion or deletion. Default
    to 3 bp, or only calls when they're within 3 bp.
  id: X
  inputBinding:
    position: 0
    prefix: -X
  type: string?
- doc: For downsampling fraction. e.g. 0.7 means roughly 70%% downsampling. Default
    - No downsampling. Use with caution. The downsampling will be random and non-reproducible.
  id: Z
  inputBinding:
    position: 0
    prefix: -Z
  type: string?
- doc: Indicate it's amplicon based calling. Reads don't map to the amplicon will
    be skipped. A read pair is considered belonging the amplicon if the edges are
    less than int bp to the amplicon, and overlap fraction is at least float. Default
    - 10 -0.95
  id: a
  inputBinding:
    position: 0
    prefix: -a
  type: string?
- doc: Tumor bam
  id: b
  secondaryFiles:
  - .bai
  type: File?
- doc: Normal bam
  id: b2
  secondaryFiles:
  - .bai
  type: File?
- id: bedfile
  inputBinding:
    position: 1
  type: File?
- default: '1'
  doc: The column for chromosome
  id: c
  inputBinding:
    position: 0
    prefix: -c
  type: string?
- doc: The delimiter for split region_info, default to tab "\t"
  id: d
  inputBinding:
    position: 0
    prefix: -d
  type: string?
- doc: The column for segment ends in the region, e.g. exon ends
  id: e
  inputBinding:
    position: 0
    prefix: -e
  type: string?
- default: '0.01'
  doc: The threshold for allele frequency, default - 0.05 or 5%%
  id: f
  inputBinding:
    position: 0
    prefix: -f
  type: string?
- doc: The column for gene name, or segment annotation
  id: g
  inputBinding:
    position: 0
    prefix: -g
  type: string?
- default: false
  doc: Print a header row decribing columns
  id: hh
  inputBinding:
    position: 0
    prefix: -hh
  type: boolean?
- default: false
  doc: Output splicing read counts
  id: i
  inputBinding:
    position: 0
    prefix: -i
  type: boolean?
- doc: Indicate whether to perform local realignment. Default - 1. Set to 0 to disable
    it. For Ion or PacBio, 0 is recommended.
  id: k
  inputBinding:
    position: 0
    prefix: -k
  type: string?
- doc: If set, reads with mismatches more than INT will be filtered and ignored. Gaps
    are not counted as mismatches. Valid only for bowtie2/TopHat or BWA aln followed
    by sampe. BWA mem is calculated as NM - Indels. Default - 8, or reads with more
    than 8 mismatches will not be used.
  id: m
  inputBinding:
    position: 0
    prefix: -m
  type: string?
- doc: The regular expression to extract sample name from bam filenames. Default to
    - /([^\/\._]+?)_[^\/]*.bam/
  id: n
  inputBinding:
    position: 0
    prefix: -n
  type: string?
- doc: The Qratio of (good_quality_reads)/(bad_quality_reads+0.5). The quality is
    defined by -q option. Default - 1.5
  id: o
  inputBinding:
    position: 0
    prefix: -o
  type: string?
- default: false
  doc: Do pileup regarless the frequency
  id: p
  inputBinding:
    position: 0
    prefix: -p
  type: boolean?
- default: '20'
  doc: The phred score for a base to be considered a good call. Default - 25 (for
    Illumina) For PGM, set it to ~15, as PGM tends to under estimate base quality.
  id: q
  inputBinding:
    position: 0
    prefix: -q
  type: string?
- doc: The minimum
  id: r
  inputBinding:
    position: 0
    prefix: -r
  type: string?
- doc: The column for segment starts in the region, e.g. exon starts
  id: s
  inputBinding:
    position: 0
    prefix: -s
  type: string?
- default: false
  doc: Indicate to remove duplicated reads. Only one pair with same start positions
    will be kept
  id: t
  inputBinding:
    position: 0
    prefix: -t
  type: boolean?
- default: '4'
  doc: Threads count.
  id: th
  inputBinding:
    position: 0
    prefix: -th
  type: string?
- default: false
  doc: Indicate to move indels to 3-prime if alternative alignment can be achieved.
  id: three
  inputBinding:
    position: 0
    prefix: '-3'
  type: boolean?
- doc: output vcf file
  id: vcf
  inputBinding:
    position: 0
    prefix: --vcf
  type: string?
- default: '2000'
  doc: The number of nucleotide to extend for each segment, default - 0 -y
  id: x
  inputBinding:
    position: 0
    prefix: -x
  type: string?
- default: '1'
  doc: Indicate wehther is zero-based cooridates, as IGV does. Default - 1 for BED
    file or amplicon BED file. Use 0 to turn it off. When use -R option, it's set
    to 0AUTHOR. Written by Zhongwu Lai, AstraZeneca, Boston, USAREPORTING BUGS. Report
    bugs to zhongwu@yahoo.comCOPYRIGHT. This is free software - you are free to change
    and redistribute it. There is NO WARRANTY, to the extent permitted by law.
  id: z
  inputBinding:
    position: 0
    prefix: -z
  type: string?
outputs:
- id: output
  outputBinding:
    glob: tmp_output.vcf
  type: File
requirements:
- class: ResourceRequirement
  coresMin: 4
  ramMin: 32000
- class: DockerRequirement
  dockerPull: roslin/pipeline-vardict:1.5.1
- class: InlineJavascriptRequirement
stderr: tmp_err.log
stdout: tmp_output.vcf
