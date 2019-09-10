$namespaces:
  dct: http://purl.org/dc/terms/
  doap: http://usefulinc.com/ns/doap#
  foaf: http://xmlns.com/foaf/0.1/
$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#
arguments:
- position: 0
  prefix: -N
  valueFrom: "${\n    return inputs.N + \"|\" + inputs.N2;\n}"
baseCommand:
- perl
- /usr/bin/vardict/var2vcf_paired.pl
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
  doap:name: VarToVcf
  doap:revision: 1.5.1
- class: doap:Version
  doap:name: MSK-App
  doap:revision: 1.0.0
doc: 'None

  '
id: cmo_vardict
inputs:
- doc: Indicate the chromosome names are just numbers, such as 1, 2, not chr1, chr2
  id: C
  inputBinding:
    position: 0
    prefix: -C
  type: boolean?
- doc: Debug mode. Will print some error messages and append full genotype at the
    end.
  id: D
  inputBinding:
    position: 0
    prefix: -D
  type: float?
- doc: The hexical to filter reads using samtools. Default - 0x500 (filter 2nd alignments
    and duplicates). Use -F 0 to turn it off.
  id: F
  inputBinding:
    position: 0
    prefix: -F
  type: float?
- doc: The indel size. Default - 120bp
  id: I
  inputBinding:
    position: 0
    prefix: -I
  type: int?
- doc: The minimum matches for a read to be considered. If, after soft-clipping, the
    matched bp is less than INT, then the read is discarded. It's meant for PCR based
    targeted sequencing where there's no insert and the matching is only the primers.
    Default - 0, or no filtering
  id: M
  inputBinding:
    position: 0
    prefix: -M
  type: boolean?
- doc: Tumor Sample Name
  id: N
  type: string?
- doc: Normal Sample Name
  id: N2
  type: string?
- doc: The read position filter. If the mean variants position is less that specified,
    it's considered false positive. Default - 5
  id: P
  inputBinding:
    position: 0
    prefix: -P
  type: float?
- doc: If set, reads with mapping quality less than INT will be filtered and ignored
  id: Q
  inputBinding:
    position: 0
    prefix: -Q
  type: string?
- doc: The column for region start, e.g. gene start
  id: S
  inputBinding:
    position: 0
    prefix: -S
  type: boolean?
- doc: The threshold for allele frequency, default - 0.05 or 5%%
  id: f
  inputBinding:
    position: 0
    prefix: -f
  type: string?
- doc: If set, reads with mismatches more than INT will be filtered and ignored. Gaps
    are not counted as mismatches. Valid only for bowtie2/TopHat or BWA aln followed
    by sampe. BWA mem is calculated as NM - Indels. Default - 8, or reads with more
    than 8 mismatches will not be used.
  id: m
  inputBinding:
    position: 0
    prefix: -m
  type: int?
- doc: The Qratio of (good_quality_reads)/(bad_quality_reads+0.5). The quality is
    defined by -q option. Default - 1.5
  id: o
  inputBinding:
    position: 0
    prefix: -o
  type: float?
- doc: Do pileup regarless the frequency
  id: p
  inputBinding:
    position: 0
    prefix: -p
  type: float?
- doc: output vcf file
  id: vcf
  type: string?
- id: A
  inputBinding:
    position: 0
    prefix: -A
  type: boolean?
- id: c
  inputBinding:
    position: 0
    prefix: -c
  type: int?
- id: q
  inputBinding:
    position: 0
    prefix: -q
  type: float?
- id: d
  inputBinding:
    position: 0
    prefix: -d
  type: int?
- id: v
  inputBinding:
    position: 0
    prefix: -v
  type: int?
- id: input_vcf
  type: File?
outputs:
- id: output
  outputBinding:
    glob: ${ if (inputs.vcf) return inputs.vcf; return null; }
  type: File
requirements:
- class: ResourceRequirement
  coresMin: 4
  ramMin: 32000
- class: DockerRequirement
  dockerPull: mskcc/roslin-variant-vardict:1.5.1
- class: InlineJavascriptRequirement
stdin: $(inputs.input_vcf.path)
stdout: "${\n  if (inputs.vcf)\n    return inputs.vcf;\n  return null;\n}\n"
