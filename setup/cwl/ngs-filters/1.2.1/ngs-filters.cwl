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
  doap:name: ngs-filters
  doap:revision: 1.2.1
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
    foaf:name: Cyriac Kandoth
    foaf:mbox: mailto:ckandoth@gmail.com
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- non-cmo.sh
- --tool
- "ngs-filters"
- --version
- "1.2.1"
- --language_version
- "default"
- --language
- "python"

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 36
    coresMin: 1

doc: |
  This tool flags false-positive somatic calls in a given MAF file

inputs:
  verbose:
    type: ['null', boolean]
    default: false
    doc: make lots of noise
    inputBinding:
      prefix: --verbose

  inputMaf:
    type: 
    - File
    doc: Input maf file which needs to be tagged
    inputBinding:
      prefix: --input-maf

  outputMaf:
    type: string
    doc: Output maf file name
    inputBinding:
      prefix: --output-maf

  NormalPanelMaf:
    type:
    - 'null'
    - string
    - File
    doc: Path to fillout maf file of panel of standard normals
    inputBinding:
      prefix: --normal-panel-maf

  NormalCohortMaf:
    type:
    - 'null'
    - string
    - File
    doc: Path to fillout maf file of cohort normals
    inputBinding:
      prefix: --normal-cohort-maf

  NormalCohortSamples:
    type: ['null', string]
    doc: File with list of normal samples
    inputBinding:
      prefix: --normalSamplesFile

  inputHSP:
    type:
    - 'null'
    - string
    - File
    doc: Input txt file which has hotspots
    inputBinding:
      prefix: --input-hotspot

outputs:
  output:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.outputMaf)
            return inputs.outputMaf;
          return null;
        }
