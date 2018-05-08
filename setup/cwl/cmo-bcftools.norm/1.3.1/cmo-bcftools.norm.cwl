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
  doap:name: cmo-bcftools.norm
  doap:revision: 1.3.1
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
# To generate again: $ cmo_bcftools norm --generate_cwl_tool
# Help: $ cmo_bcftools norm --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand: [cmo_bcftools]
label: cmo-bcftools(norm)

arguments:
- valueFrom: "norm"
  position: 0

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 16000
    coresMin: 1

doc: |
  left-align and normalize indels

inputs:
  threads:
    type: ['null', string]
    doc: <int> number of extra output compression threads [0]
    inputBinding:
      prefix: --threads

  check_ref:
    type: ['null', string]
    doc: <e|w|x|s> check REF alleles and exit (e), warn (w), exclude (x), or set (s)
      bad sites [e]
    inputBinding:
      prefix: --check-ref
    default: s

  remove_duplicates:
    type: ['null', boolean]
    default: false
    doc: remove duplicate lines of the same type.
    inputBinding:
      prefix: --remove-duplicates

  output_type:
    type: ['null', string]
    doc: <type> 'b' compressed BCF; '' uncompressed BCF; 'z' compressed VCF; 'v' uncompressed
      VCF [v]
    inputBinding:
      prefix: --output-type

  no_version:
    type: ['null', boolean]
    default: false
    doc: do not append version and command line to the header
    inputBinding:
      prefix: --no-version

  site_win:
    type: ['null', string]
    doc: <int> buffer for sorting lines which changed position during realignment
      [1000]
    inputBinding:
      prefix: --site-win

  rm_dup:
    type: ['null', string]
    doc: <type> remove duplicate snps|indels|both|any
    inputBinding:
      prefix: --rm-dup

  regions:
    type: ['null', string]
    doc: <region> restrict to comma-separated list of regions
    inputBinding:
      prefix: --regions

  regions_file:
    type: ['null', string]
    doc: <file> restrict to regions listed in a file
    inputBinding:
      prefix: --regions-file

  multiallelics:
    type: ['null', string]
    doc: <-|+>[type] split multiallelics (-) or join biallelics (+), type - snps|indels|both|any
      [both]
    inputBinding:
      prefix: --multiallelics

  targets:
    type: ['null', string]
    doc: <region> similar to -r but streams rather than index-jumps
    inputBinding:
      prefix: --targets

  targets_file:
    type: ['null', string]
    doc: <file> similar to -R but streams rather than index-jumps
    inputBinding:
      prefix: --targets-file

  output:
    type: ['null', string]
    doc: <file> write output to a file [standard output]
    inputBinding:
      prefix: --output

  strict_filter:
    type: ['null', boolean]
    default: false
    doc: when merging (-m+), merged site is PASS only if all sites being merged PASS
    inputBinding:
      prefix: --strict-filter

  do_not_normalize:
    type: ['null', boolean]
    default: false
    doc: do not normalize indels (with -m or -c s)
    inputBinding:
      prefix: --do-not-normalize

  fasta_ref:
    type:
    - 'null'
    - string
    inputBinding:
      prefix: --fasta-ref

  vcf:
    type: 


    - string
    - File
    inputBinding:
      position: 1


outputs:
  vcf_output_file:
    type: File
    outputBinding:
      glob: |-
        ${
          if (inputs.output)
            return inputs.output;
          return null;
        }
