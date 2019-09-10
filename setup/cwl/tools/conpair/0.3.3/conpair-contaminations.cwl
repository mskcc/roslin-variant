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
  doap:name: conpair-contamination.cwl
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
    foaf:name: Christopher Harris
    foaf:mbox: mailto:harrisc2@mskcc.org

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand: [contamination]

id: conpair-contamination
requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 16000
    coresMin: 1
  DockerRequirement:
    dockerPull: mskcc/roslin-variant-conpair:0.3.3

doc: |
  None

inputs:
  tpileup:
    type:
      type: array
      items: File
    inputBinding:
      prefix: --tumor_pileup

  npileup:
    type:
      type: array
      items: File
    inputBinding:
      prefix: --normal_pileup

  markers:
    type:
    - [File, string]
    inputBinding:
      prefix: --markers

  pairing_file:
    type: File
    inputBinding:
      prefix: --pairing

  output_prefix:
    type: string
    inputBinding:
      prefix: --outpre

  output_directory_name:
    type: string
    default: "."
    inputBinding:
      prefix: --outdir

outputs:
  outfiles:
    type: File[]?
    outputBinding:
      glob: |
        ${
          if (inputs.output_directory_name + "/" + inputs.output_prefix + "_contamination*.*")
            return inputs.output_directory_name + "/" + inputs.output_prefix + "_contamination*.*";
          return null;
        }

  pdf:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.output_directory_name + "/" + inputs.output_prefix + "_contamination*.pdf")
            return inputs.output_directory_name + "/" + inputs.output_prefix + "_contamination*.pdf";
          return null;
        }
