#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#

doap:name: flatten-array.cwl
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
      items:
        type: array
        items: File
    secondaryFiles: ['^.bai']

outputs:

  bams:
    type:
      type: array
      items: File
    secondaryFiles: ['^.bai']

expression: ${var samples = []; for (var i = 0; i < inputs.bams.length; i++) { for (var j =0; j < inputs.bams[i].length; j++) { samples.push(inputs.bams[i][j]) } } return {"bams":samples};}
