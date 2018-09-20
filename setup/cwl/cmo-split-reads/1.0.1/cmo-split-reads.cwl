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
  doap:name: cmo-split-reads
  doap:revision: 1.0.0
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
# To generate again: $ cmo_split_reads -o FILENAME --generate_cwl_tool
# Help: $ cmo_split_reads  --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand: [cmo_split_reads]
label: cmo-split-reads

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 24000
    coresMin: 1


doc: |
  split files into chunks based on filesize

inputs:
  fastq1:
    type: string

    doc: filename to split
    inputBinding:
      prefix: --fastq1

  fastq2:
    type: string
    doc: filename2 to split
    inputBinding:
      prefix: --fastq2

  platform_unit:
    type: 

    - 'null'
    - string
    doc: RG/PU ID
    inputBinding:
      prefix: --platform-unit


outputs:

  chunks1:
    type:
      type: array
      items: File
    outputBinding:
      glob: |
        ${
          var pattern = '*-R1-*chunk*.fastq.gz';
          if (inputs.sample)
            pattern = inputs.sample + pattern;
          return pattern
        }

  chunks2:
    type:
      type: array
      items: File
    outputBinding:
      glob: |
        ${
          var pattern = '*-R2-*chunk*.fastq.gz';
          if (inputs.sample)
            pattern = inputs.sample + pattern;
          return pattern
        }
