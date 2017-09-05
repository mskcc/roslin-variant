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
  doap:name: cmo-qcpdf
  doap:revision: 0.5.5
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
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_qcpdf -o FILENAME --generate_cwl_tool
# Help: $ cmo_qcpdf  --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['cmo_qcpdf']

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 5
    coresMin: 1


doc: |
  Do Dat PostProcessing

inputs:
  
  qc_version:
    type: ["null", string]
    default: default
    doc: destination of filtered output
    inputBinding:
      prefix: --qc-version 

  R_version:
    type:
    - "null"
    - type: enum
      symbols: ['default']
    default: 3.1.2
    doc: Run QC PDF generation
    inputBinding:
      prefix: --R-version 

  pre:
    type: ["null", string]
    default: Project
    doc: project prefix
    inputBinding:
      prefix: --pre 

  metrics_directory:
    type: string
  
    doc: pipeline generated metrics directory
    inputBinding:
      prefix: --metrics-directory 


outputs:
  qc_files:
      type:
        type: array
        items: File
      outputBinding:
        glob: |
          ${
              return inputs.file_prefix + "*";
          }
