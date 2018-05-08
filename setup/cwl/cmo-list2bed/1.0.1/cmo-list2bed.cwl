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
  doap:name: cmo-list2bed
  doap:revision: 1.0.1
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
baseCommand: [cmo_list2bed]
label: cmo_list2bed

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 2
    coresMin: 1

doc: |
  Convert a Picard interval list file to a UCSC BED format

inputs:
  input_file:
    type: 

    - string
    - File
    - type: array
      items: string
    doc: picard interval list
    inputBinding:
      prefix: --input_file

  no_sort:
    type: ['null', boolean]
    default: true
    doc: sort bed file output
    inputBinding:
      prefix: --no_sort


  output_filename:
    type: string
    doc: output bed file
    inputBinding:
      prefix: --output_file
outputs:
  output_file:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.output_filename)
            return inputs.output_filename;
          return null;
        }
