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
  doap:name: flatten-array-fastq
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
label: flatten-array-fastq
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
  add_rg_ID:
    type:
      type: array
      items: string
  add_rg_PU:
    type:
      type: array
      items: string


outputs:

  chunks1:
    type:
      type: array
      items: File
  chunks2:
    type:
      type: array
      items: File
  rg_ID:
    type:
      type: array
      items: string
  rg_PU:
    type:
      type: array
      items: string


expression: "${
    var fastq1 = [];
    var fastq2 =[];
    var add_rg_ID = [];
    var add_rg_PU = [];
    for (var i = 0; i < inputs.fastq1.length; i++) {
        for (var j =0; j < inputs.fastq1[i].length; j++) {
            fastq1.push(inputs.fastq1[i][j]);
            fastq2.push(inputs.fastq2[i][j]);
        }
    }
    fastq1 = fastq1.sort(function(a,b) {  if (a['basename']< b['basename']) { return -1; } else if(a['basename'] > b['basename']) { return 1; } else { return 0; } });
    fastq2 = fastq2.sort(function(a,b) { if (a['basename']< b['basename']) { return -1; } else if(a['basename'] > b['basename']) { return 1; } else { return 0; }});
    for (var i =0; i < fastq1.length; i++) {
        for(var j=0; j < inputs.add_rg_PU.length; j++) {
            if (fastq1[i].basename.includes(inputs.add_rg_PU[j])) {
                add_rg_ID.push(inputs.add_rg_ID[j]);
                add_rg_PU.push(inputs.add_rg_PU[j]);
            }
        }
    }
    var returnobj = {};
    returnobj['chunks1'] = fastq1;
    returnobj['chunks2'] = fastq2;
    returnobj['rg_ID']= add_rg_ID;
    returnobj['rg_PU']= add_rg_PU;
    return returnobj;
}"
