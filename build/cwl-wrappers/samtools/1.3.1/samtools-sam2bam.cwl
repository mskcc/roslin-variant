#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#

doap:name: samtools-sam2bam.cwl
doap:release:
- class: doap:Version
  doap:revision: '1.3.1'

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

cwlVersion: v1.0

class: CommandLineTool
baseCommand: ["sing.sh", "samtools", "1.3.1"]
arguments:
  - id: samtools-command
    valueFrom: "view -bh"

requirements:
  ResourceRequirement:
    ramMin: 1
    coresMin: 1

inputs:
  sam:
    type: File
    inputBinding:
      position: 1
  output_filename:
    type: string
    inputBinding:
      position: 2
      prefix: -o
    
outputs:
  bam:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
