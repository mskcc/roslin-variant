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
  doap:name: stitch-pdf
  doap:revision: 1.0.0
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org
cwlVersion: v1.0

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing: $(inputs.data_dir.listing)

  ResourceRequirement:
    ramMin: 8000
    coresMin: 1

class: CommandLineTool
baseCommand:
- tool.sh
- --tool
- "roslin-qc"
- --version
- "0.6.0"
- --cmd
- genlatex
id: genlatex

inputs:

  data_dir:
    type: Directory

  input_dir:
    type: [ 'null', string ]
    default: "."
    inputBinding:
      prefix: --path

  request_file:
    type: File
    inputBinding:
      prefix: --request_file

  project_prefix:
    type: [ 'null', string ]
    inputBinding:
      prefix: --full_project_name

outputs:
  qc_pdf:
    type: File
    outputBinding:
      glob: "*_QC_Report.pdf"

