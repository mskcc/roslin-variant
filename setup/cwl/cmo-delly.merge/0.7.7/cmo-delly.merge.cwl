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
  doap:name: cmo-delly.merge
  doap:revision: 0.7.7
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

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand: [cmo_delly]
id: cmo-delly-merge

arguments:
- valueFrom: "0.7.7"
  prefix: --version
  position: 0
- valueFrom: "merge"
  prefix: --cmd
  position: 0

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 8000
    coresMin: 1

doc: |
  None

inputs:
  t:
    type: ['null', string]
    default: DEL
    doc: SV type (DEL, DUP, INV, BND, INS)
    inputBinding:
      prefix: --type

  o:
    type: ['null', string]
    default: sv.bcf
    doc: Merged SV BCF output file
    inputBinding:
      prefix: --outfile

  m:
    type: ['null', int]
    default: 0
    doc: min. SV size
    inputBinding:
      prefix: --minsize

  n:
    type: ['null', int]
    default: 1000000
    doc: max. SV size
    inputBinding:
      prefix: --maxsize

  c:
    type: ['null', boolean]
    default: false
    doc: Filter sites for PRECISE
    inputBinding:
      prefix: --precise

  p:
    type: ['null', boolean]
    default: false
    doc: Filter sites for PASS
    inputBinding:
      prefix: --pass

  b:
    type: ['null', int]
    default: 1000
    doc: max. breakpoint offset
    inputBinding:
      prefix: --bp-offset

  r:
    type: ['null', float]
    default: 0.800000012
    doc: min. reciprocal overlap
    inputBinding:
      prefix: --rec-overlap

  i:
    type:
      type: array
      items: File
    inputBinding:
      prefix: --input
      itemSeparator: ' '
      separate: true
    doc: Input files (.bcf)
  all_regions:
    type: ['null', boolean]
    default: false
    doc: include regions marked in this genome
    inputBinding:
      prefix: --all_regions

  stderr:
    type: ['null', string]
    doc: log stderr to file
    inputBinding:
      prefix: --stderr

  stdout:
    type: ['null', string]
    doc: log stdout to file
    inputBinding:
      prefix: --stdout


outputs:
  sv_file:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.o)
            return inputs.o;
          return null;
        }
