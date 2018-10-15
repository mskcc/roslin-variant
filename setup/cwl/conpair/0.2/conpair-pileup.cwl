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
  doap:name: conpair-pileup.cwl
  doap:revision: 0.2
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

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- tool.sh
- --tool
- "conpair_pileup"
- --version
- "0.2"
- --language_version
- "default"
- --language
- "python"
id: conpair-pileup

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 16000
    coresMin: 1

doc: |
  None

inputs:

  ref:
    type:
    - [File, string]
    inputBinding:
      prefix: --reference
    secondaryFiles:
      - ^.dict
      - ^.fasta.fai
      
  java_xmx:
    type:
    - 'null'
    - type: array
      items: string
    doc: set up java -Xmx parameter
    inputBinding:
      prefix: --xmx_java
      
  gatk:
    type:
    - [File, string, "null"]
    inputBinding:
      prefix: --gatk

  markers_bed:
    type:
    - [File, string]
    inputBinding:
      prefix: --markers
      
  bam:
    type:
    - [File, string]
    inputBinding:
      prefix: --bam
    secondaryFiles:
      - ^.bai

  outfile:
    type:
    - string
    inputBinding:
      prefix: --outfile

outputs:
  out_file:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.outfile)
            return inputs.outfile;
          return null;
        }
