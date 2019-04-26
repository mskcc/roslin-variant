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
  doap:name: cmo-delly.filter
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

cwlVersion: v1.0

class: CommandLineTool
baseCommand: [cmo_delly]
id: cmo-delly-filter

arguments:
- valueFrom: "0.7.7"
  prefix: --version
  position: 0
- valueFrom: "filter"
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

  f:
    type: ['null', string]
    default: somatic
    doc: Filter mode (somatic, germline)
    inputBinding:
      prefix: --filter

  o:
    type: ['null', string]
    default: sv.bcf
    doc: Filtered SV BCF output file
    inputBinding:
      prefix: --outfile

  a:
    type: ['null', float]
    default: 0.04
    doc: min. fractional ALT support
    inputBinding:
      prefix: --altaf

  m:
    type: ['null', int]
    default: 500
    doc: min. SV size
    inputBinding:
      prefix: --minsize

  n:
    type: ['null', int]
    default: 500000000
    doc: max. SV size
    inputBinding:
      prefix: --maxsize

  r:
    type: ['null', float]
    default: 0.0
    doc: min. fraction of genotyped samples
    inputBinding:
      prefix: --ratiogeno

  p:
    type: ['null', boolean]
    default: true
    doc: Filter sites for PASS
    inputBinding:
      prefix: --pass

  s:
    type: File
    doc: Two-column sample file listing sample name and tumor or control
    inputBinding:
      prefix: --samples

  v:
    type: ['null', int]
    default: 10
    doc: min. coverage in tumor
    inputBinding:
      prefix: --coverage

  c:
    type: ['null', int]
    default: 0
    doc: max. fractional ALT support in control
    inputBinding:
      prefix: --controlcontamination

  q:
    type: ['null', int]
    default: 15
    doc: min. median GQ for carriers and non-carriers
    inputBinding:
      prefix: --gq

  e:
    type: ['null', float]
    default: 0.800000012
    doc: max. read-depth ratio of carrier vs. non-carrier for a deletion
    inputBinding:
      prefix: --rddel

  u:
    type: ['null', float]
    default: 1.20000005
    doc: min. read-depth ratio of carrier vs. non-carrier for a duplication
    inputBinding:
      prefix: --rddup

  i:
    type: File
    inputBinding:
      prefix: --input
    doc: Input file (.bcf)

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
    secondaryFiles: 
      - ^.bcf.csi
    outputBinding:
      glob: |
        ${
          if (inputs.o)
            return inputs.o;
          return null;
        }
