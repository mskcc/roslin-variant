#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#

doap:name: cmo-index.cwl
doap:release:
- class: doap:Version
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Christopher Harris
    foaf:mbox: mailto:harrisc2@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Christopher Harris
    foaf:mbox: mailto:harrisc2@mskcc.org
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- cmo_index
- --version
- "2.9"
requirements:
  ResourceRequirement:
    ramMin: 15
    coresMin: 1

inputs:

  tumor:
    type: File
    inputBinding:
        prefix: --tumor
  normal:
    type: File
    inputBinding:
        prefix: --normal
    doc: picard interval list

outputs:

  tumor_bam: 
    type: File
    outputBinding:
      glob: $(inputs.tumor.basename)
    secondaryFiles: ["^.bai", ".bai"]
  normal_bam: 
    type: File
    outputBinding:
      glob: $(inputs.normal.basename)
    secondaryFiles: ["^.bai", ".bai"]
