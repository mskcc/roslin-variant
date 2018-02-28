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
  doap:name: cmo-facets.geneLevel
  doap:revision: 1.5.5
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Cyriac Kandoth
    foaf:mbox: mailto:kandothc@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Cyriac Kandoth
    foaf:mbox: mailto:kandothc@mskcc.org
  - class: foaf:Person
    foaf:name: Allan Bolipatan
    foaf:mbox: mailto:bolipatc@mskcc.org


cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- non-cmo.sh
- --tool
- "facets"
- --version
- "1.5.6"
- --language_version
- "default"
- --language
- "python"
- geneLevel

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 7
    coresMin: 1

doc: |
  Generate gene-level somatic CNA calls, given the .cncf.txt file from a run of doFACETS

inputs:
  filenames:
    type:
        type: array
        items: File
    doc: File(s) to be processed
    inputBinding:
      prefix: --filenames

  outfilename:
    type: string
    doc: Output filename
    inputBinding:
      prefix: --outfile

  targetFile:
    type: string
    default: "IMPACT468"
    doc: IMPACT341/410/468, or a Picard interval list file of gene target coordinates
    inputBinding:
      prefix: --targetFile

  method:
    type: string
    default: "reg"
    inputBinding:
      prefix: --method

outputs:
  outfile:
    type: File[]
    outputBinding:
      glob: "*.txt" 
