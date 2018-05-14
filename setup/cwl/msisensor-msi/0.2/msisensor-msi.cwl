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
  doap:name: msisensor-msi
  doap:revision: 0.2 #current version of msisensor
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
    foaf:name: Timothy Song
    foaf:mbox: mailto:songt@mskcc.org


cwlVersion: cwl:v1.0

# class: CommandLineTool
# baseCommand: [tool.sh]
# label: msisensor

# arguments:
# - valueFrom: "msisensor"
#   prefix: --tool
#   position: 0
# - valueFrom: "0.2"
#   prefix: --version
#   position: 0
# - valueFrom: "default"
#   prefix: --language_version
#   position: 0
# - valueFrom: "bash"
#   prefix: --language
#   position: 0
# - valueFrom: "msi"
#   prefix: --cmd
#   position: 0
class: CommandLineTool
baseCommand:
- non-cmo.sh
- --tool
- "msisensor"
- --version
- "0.2"
- --language_version
- "default"
- --language
- "bash"
- msi

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 16
    coresMin: 2

doc: |
  Run msisensor on tumor-normal bams to differentiate MSI (microsatellite instable) samples from MSS (microsatellite stable) ones

inputs:
  d:
    type:
    - string
    - File
    doc: homopolymer and microsatellites file
    inputBinding:
      prefix: -d

  n:
    type:
    - File
    doc: normal bam file
    secondaryFiles: ["^.bai"]
    inputBinding:
      prefix: -n

  t:
    type:
    - File
    doc: tumor bam file
    secondaryFiles: ["^.bai"]
    inputBinding:
      prefix: -t

  o:
    type: string
    doc: output distribution file
    inputBinding:
      prefix: -o

#below are optional inputs
  e:
    type: ['null', string]
    doc: bed file, to select a few regions
    inputBinding:
      prefix: -e

  f:
    type: ['null', double]
    doc: FDR threshold for somatic sites detection
    default: 0.05
    inputBinding:
      prefix: -f

  r:
    type: ['null', string]
    doc: choose one region, format 1:10000000-20000000
    inputBinding:
      prefix: -r

  l:
    type: ['null', int]
    default: 5
    doc: minimal homopolymer size
    inputBinding:
      prefix: -l

  p:
    type: ['null', int]
    default: 10
    doc: minimal homopolymer size for distribution analysis
    inputBinding:
      prefix: -p

  m:
    type: ['null', int]
    default: 50
    doc: maximal homopolymer size for distribution analysis
    inputBinding:
      prefix: -m

  q:
    type: ['null', int]
    default: 3
    doc: minimal microsatellites size
    inputBinding:
      prefix: -q

  s:
    type: ['null', int]
    default: 5
    doc: minimal number of repeats in microsatellites for distribution analysis
    inputBinding:
      prefix: -s

  w:
    type: ['null', int]
    default: 40
    doc: maximal microsatellites size for distribution analysis
    inputBinding:
      prefix: -w

  u:
    type: ['null', int]
    default: 500
    doc: span size around window for extracting reads
    inputBinding:
      prefix: -u

  b:
    type: ['null', int]
    default: 2
    doc: threads number for parallel computing
    inputBinding:
      prefix: -b

  x:
    type: ['null', int]
    default: 0
    doc: output homopolymer only, 0 is no, 1 is yes
    inputBinding:
      prefix: -x

  y:
    type: ['null', int]
    default: 0
    doc: output microsatellite only, 0 is no, 1 is yes
    inputBinding:
      prefix: -y

outputs:
  output:
    type: File
    outputBinding:
      glob: |-
        ${
          if (inputs.o)
            return inputs.o;
          return null;
        }
