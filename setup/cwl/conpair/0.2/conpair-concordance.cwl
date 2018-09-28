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
  doap:name: conpair-concordance.cwl
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
baseCommand: [tool.sh]
label: conpair-concordance

arguments:
- valueFrom: "conpair_concordance"
  prefix: --tool
  position: 0
- valueFrom: "0.2"
  prefix: --version
  position: 0
- valueFrom: "default"
  prefix: --language_version
  position: 0
- valueFrom: "python"
  prefix: --language
  position: 0

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 16000
    coresMin: 1

doc: |
  None

inputs:
  normal_homozygous:
    type: boolean
    default: true
    inputBinding:
      prefix: --normal_homozygous_markers_only

  tpileup:
    type:
    - [File, string]
    inputBinding:
      prefix: --tumor_pileup
      
  npileup:
    type:
    - [File, string]
    inputBinding:
      prefix: --normal_pileup
      
  markers:
    type:
    - [File, string]
    inputBinding:
      prefix: --markers

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
