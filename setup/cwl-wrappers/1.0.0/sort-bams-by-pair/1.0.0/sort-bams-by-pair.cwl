#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#

doap:name: sort-bams-by-pair.cwl
doap:release:
- class: doap:Version
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
requirements:
  - class: InlineJavascriptRequirement

inputs:

  bams:
    type:
      type: array
      items: File
  pairs:
    type:
      type: array
      items:
        type: array
        items: string

outputs:

  tumor_bams:
    type:
      type: array
      items: File
  normal_bams:
    type:
      type: array
      items: File
  tumor_sample_ids:
    type:
      type: array
      items: string
  normal_sample_ids:
    type:
      type: array
      items: string

expression: "${var samples = {}; for (var i = 0; i < inputs.bams.length; i++) { var matches = inputs.bams[i].basename.match(/([^.]*)./); samples[matches[1]]=inputs.bams[i]; } var tumor_bams = [], tumor_sample_ids=[]; var normal_bams = [], normal_sample_ids=[]; for (var i=0; i < inputs.pairs.length; i++) { tumor_bams.push(samples[inputs.pairs[i][0]]); normal_bams.push(samples[inputs.pairs[i][1]]); tumor_sample_ids.push(inputs.pairs[i][0]); normal_sample_ids.push(inputs.pairs[i][1]); } return {'tumor_bams': tumor_bams, 'normal_bams': normal_bams, 'tumor_sample_ids': tumor_sample_ids, 'normal_sample_ids': normal_sample_ids};}"
