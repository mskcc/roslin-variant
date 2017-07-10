#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- file:///ifs/work/chunj/prism-proto/prism/schemas/dcterms.rdf
- file:///ifs/work/chunj/prism-proto/prism/schemas/foaf.rdf
- file:///ifs/work/chunj/prism-proto/prism/schemas/doap.rdf

doap:release:
- class: doap:Version
  doap:name: flatten-array-fastq.cwl
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

  fastq1:
    type:
    - File
    - type: array
      items:
        type: array
        items: File
  fastq2:
    type:
    - File
    - type: array
      items:
        type: array
        items: File

outputs:

  chunks1:
    type:
      type: array
      items: File
  chunks2:
    type:
      type: array
      items: File


expression: ${var fastq1 = []; var fastq2 =[]; for (var i = 0; i < inputs.fastq1.length; i++) { for (var j =0; j < inputs.fastq1[i].length; j++) { fastq1.push(inputs.fastq1[i][j]); fastq2.push(inputs.fastq2[i][j]); } } return {"chunks1":fastq1.sort(function(a,b) {  if (a["basename"]< b["basename"]) { return -1; } else if(a["basename"] > b["basename"]) { return 1; } else { return 0; } }),"chunks2":fastq2.sort(function(a,b) { if (a["basename"]< b["basename"]) { return -1; } else if(a["basename"] > b["basename"]) { return 1; } else { return 0; }})}}
