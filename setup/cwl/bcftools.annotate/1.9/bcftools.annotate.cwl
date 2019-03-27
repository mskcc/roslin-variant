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
  doap:name: bcftools.annotate
  doap:revision: 1.9
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Nikhil Kumar
    foaf:mbox: mailto:kumarn1@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Nikhil Kumar
    foaf:mbox: mailto:kumarn1@mskcc.org

cwlVersion: v1.0

class: CommandLineTool
baseCommand:
- tool.sh
- --tool
- "htslib"
- --version
- "1.9"
- --cmd
- "annotate"
id: bcftools-annotate

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 8000
    coresMin: 1

doc: |
  Annotate and edit VCF/BCF files.

inputs:

  annotations:
    type: ["null", File]
    doc: VCF file or tabix-indexed file with annotations CHR\tPOS[\tVALUE]+
    inputBinding:
      prefix: --annotations

  threads:
    type: ["null", string]
    doc: <int> Number of extra output compression threads [0]
    inputBinding:
      prefix: --threads

  collapse:
    type: ["null", string]
    doc: matching records by <snps|indels|both|all|some|none>, see man page for details [some]
    inputBinding:
      prefix: --collapse

  columns:
    type:
      - 'null'
      - type: array
        items: string
    doc: list of columns in the annotation file, e.g. CHROM,POS,REF,ALT,-,INFO/TAG. See man page for details
    inputBinding:
      itemSeparator: ","
      prefix: --columns

  exclude:
    type: ["null", string]
    doc: exclude sites for which the expression is true (see man page for details)
    inputBinding:
      prefix: --exclude

  header_lines:
    type: ["null", File]
    doc: lines which should be appended to the VCF header
    inputBinding:
      prefix: --header-lines

  set_id:
    type: ["null", string]
    doc: set ID column, see man page for details
    inputBinding:
      prefix: --set-id

  include:
    type: ["null", string]
    doc: select sites for which the expression is true (see man page for details)
    inputBinding:
      prefix: --include

  keep_sites:
    type: ["null", boolean]
    doc: leave -i/-e sites unchanged instead of discarding them
    inputBinding:
      prefix: --keep-sites

  mark_sites:
    type: ["null", string]
    doc: add INFO/tag flag to sites which are ("+") or are not ("-") listed in the -a file
    inputBinding:
      prefix: --mark-sites

  no_version:
    type: ["null", boolean]
    default: false
    doc: do not append version and command line to the header
    inputBinding:
      prefix: --no-version

  output:
    type: string
    doc: <file> Write output to a file [standard output]
    default: "bcftools_annotate.vcf"
    inputBinding:
      prefix: --output

  output_type:
    type: ["null", string]
    doc: <b|u|z|v> b - compressed BCF, u - uncompressed BCF, z - compressed VCF, v - uncompressed VCF [v]
    inputBinding:
      prefix: --output-type

  regions:
    type: ["null", string]
    doc: <region> Restrict to comma-separated list of regions
    inputBinding:
      prefix: --regions

  regions_file:
    type: ["null", string]
    doc: <file> Restrict to regions listed in a file
    inputBinding:
      prefix: --regions-file

  rename_chrs:
    type: ["null", File]
    doc: First coordinate of the next file can precede last record of the current file.
    inputBinding:
      prefix: --rename-chrs

  samples:
    type:
      - 'null'
      - type: array
        items: string
    doc: Do not output PS tag at each site, only at the start of a new phase set block.
    inputBinding:
      itemSeparator: ","
      prefix: --samples


  samples_file:
    type: ["null", File]
    doc: First coordinate of the next file can precede last record of the current file.
    inputBinding:
      prefix: --samples-file

  remove:
    type:
      - 'null'
      - type: array
        items: string
    doc: Do not output PS tag at each site, only at the start of a new phase set block.
    inputBinding:
      itemSeparator: ","
      prefix: --remove

  vcf_file:
    type: File
    doc: Vcf file to be annotated
    inputBinding:
        position: 1

  vcf_file_index:
    type: File
    doc: Index of the vcf file

  vcf_files_tbi:
    type:
      - 'null'
      - type: array
        items: File
    secondaryFiles:
        - .tbi
    doc: Array of vcf files to be concatenated into one vcf
    inputBinding:
        position: 1

  vcf_files_tbi:
    type:
      - 'null'
      - type: array
        items: File
    secondaryFiles:
        - .tbi
    doc: Array of vcf files to be concatenated into one vcf
    inputBinding:
        position: 1

  vcf_files_csi:
    type:
      - 'null'
      - type: array
        items: File
    secondaryFiles:
      - ^.bcf.csi
    doc: Array of vcf files to be concatenated into one vcf
    inputBinding:
        position: 1


outputs:
  annotate_vcf_output_file:
    type: File
    outputBinding:
      glob: |-
        ${
          if (inputs.output)
            return inputs.output;
          return null;
        }
