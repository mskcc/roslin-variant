#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- file:///juno/work/ci/nikhil/roslin-pipelines-dev/2.1.0/schemas/dcterms.rdf
- file:///juno/work/ci/nikhil/roslin-pipelines-dev/2.1.0/schemas/foaf.rdf
- file:///juno/work/ci/nikhil/roslin-pipelines-dev/2.1.0/schemas/doap.rdf

doap:release:
- class: doap:Version
  doap:name: flatten-array-directory
  doap:revision: 1.0.0
- class: doap:Version
  doap:name: cwl-wrapper
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

cwlVersion: v1.0

class: ExpressionTool
id: flatten-array-directory
requirements:
  - class: InlineJavascriptRequirement

inputs:

  directory_list:
    type:
      type: array
      items: Directory

outputs:

  output_directory: Directory

expression: "${ if (inputs.directory_list.length != 0) { return {'output_directory':inputs.directory_list[0]}; } else { return { 'output_directory': {'class': 'Directory','basename': 'empty','listing': []} }}; }"