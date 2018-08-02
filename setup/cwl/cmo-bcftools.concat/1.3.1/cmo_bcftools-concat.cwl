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
  doap:name: cmo-bcftools.concat
  doap:revision: 1.3.1
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Zuojian Tang
    foaf:mbox: mailto:tangz@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Zuojian Tang
    foaf:mbox: mailto:tangz@mskcc.org
  - class: foaf:Person
    foaf:name: Cyriac Kandoth
    foaf:mbox: mailto:ckandoth@gmail.com

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand: [cmo_bcftools, concat]

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 8
    coresMin: 1

doc: |
  concatenate VCF/BCF files from the same set of samples

inputs:
  
  threads:
    type: ["null", str]
    doc: <int> Number of extra output compression threads [0]
    inputBinding:
      prefix: --threads 

  compact_PS:
    type: ["null", boolean]
    default: False
    doc: Do not output PS tag at each site, only at the start of a new phase set block.
    inputBinding:
      prefix: --compact-PS 

  remove_duplicates:
    type: ["null", boolean]
    default: False
    doc: Alias for -d none
    inputBinding:
      prefix: --remove-duplicates 

  ligate:
    type: ["null", boolean]
    default: False
    doc: Ligate phased VCFs by matching phase at overlapping haplotypes
    inputBinding:
      prefix: --ligate 

  output_type:
    type: ["null", str]
    doc: <b|u|z|v> b - compressed BCF, u - uncompressed BCF, z - compressed VCF, v - uncompressed VCF [v]
    inputBinding:
      prefix: --output-type 

  no_version:
    type: ["null", boolean]
    default: False
    doc: do not append version and command line to the header
    inputBinding:
      prefix: --no-version 

  naive:
    type: ["null", boolean]
    default: False
    doc: Concatenate BCF files without recompression (dangerous, use with caution)
    inputBinding:
      prefix: --naive 

  allow_overlaps:
    type: ["null", boolean]
    default: False
    doc: First coordinate of the next file can precede last record of the current file.
    inputBinding:
      prefix: --allow-overlaps 

  min_PQ:
    type: ["null", str]
    doc: <int> Break phase set if phasing quality is lower than <int> [30]
    inputBinding:
      prefix: --min-PQ 

  regions_file:
    type: ["null", str]
    doc: <file> Restrict to regions listed in a file
    inputBinding:
      prefix: --regions-file 

  regions:
    type: ["null", str]
    doc: <region> Restrict to comma-separated list of regions
    inputBinding:
      prefix: --regions 

  rm_dups:
    type: ["null", str]
    doc: <string> Output duplicate records present in multiple files only once - <snps|indels|both|all|none>
    inputBinding:
      prefix: --rm-dups 

  output:
    type: ["null", str]
    doc: <file> Write output to a file [standard output]
    inputBinding:
      prefix: --output 

  list:
    type: ['null', string]
    doc: <file> Read the list of files from a file.
    inputBinding:
      prefix: --file-list 

  vcf_vardict:
    type:
    - string
    - File
    inputBinding:
      position: 1
    secondaryFiles:
      - ^.tbi

  vcf_mutect:
    type:
    - string
    - File
    inputBinding:
      position: 2
    secondaryFiles:
      - ^.tbi

  vcf_pindel:
    type:
    - string
    - File
    inputBinding:
      position: 3
    secondaryFiles:
      - ^.tbi

outputs:
  concat_vcf_output_file:
    type: File
    outputBinding:
      glob: |-
        ${
          if (inputs.output)
            return inputs.output;
          return null;
        }
