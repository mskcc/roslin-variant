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
  doap:name: parse-pairs-and-vcfs
  doap:revision: 1.0.0
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Nikhil Kumar
    foaf:mbox: mailto:kumarn1@mskcc.org

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
  - class: foaf:Person
    foaf:name: Nikhil Kumar
    foaf:mbox: mailto:kumarn1@mskcc.org

cwlVersion: v1.0

class: ExpressionTool
id: parse-pairs-and-vcfs
requirements:
  - class: InlineJavascriptRequirement

inputs:
  bams:
    type:
      type:  array
      items:
        type: array
        items: File
  genome: string
  vep_data:
    type:
      type: array
      items: string
  exac_filter:
    type:
      type: array
      items: File
    secondaryFiles:
      - .tbi
  ref_fasta:
    type:
      type: array
      items: string
  vep_path:
    type:
      type: array
      items: string
  custom_enst:
    type:
      type: array
      items: string
  combine_vcf:
    type:
      type: array
      items: File
  pairs:
    type:
      type: array
      items:
        type: array
        items: string
  curated_bams:
    type:
      type: array
      items:
        type: array
        items: File
    secondaryFiles:
      - ^.bai
  hotspot_list:
     type:
       type: array
       items: File
outputs:
  tumor_id:
     type:
       type: array
       items: string
  normal_id:
     type:
       type: array
       items: string  
  srt_combine_vcf:
    type:
      type: array
      items: File  
  srt_ref_fasta:
     type:
       type: array
       items: string
  srt_vep_path:
    type:
      type: array
      items: string
  srt_custom_enst:
    type:
      type: array
      items: string
  srt_genome: string
  srt_exac_filter:
     type:
       type: array
       items: File
  srt_vep_data:
     type:
       type: array
       items: string
  srt_bams:
     type:
       type: array
       items: File
  srt_curated_bams:
     type:
       type: array
       items: File
  srt_hotspot_list: File

expression: '${var bams= [];
 for (var i=0; i< inputs.bams.length; i++) {
     for (var j=0; j<inputs.bams[i].length; j++) { bams.push(inputs.bams[i][j]);
     }
 }
 var combine_vcf = inputs.combine_vcf; 
 var pairs = inputs.pairs;
 var arrays = [combine_vcf];
 var final_answers = [];
 for (var m=0; m < arrays.length+8; m++) {
     final_answers[m]=new Array();
 }
  for (var i=0; i < pairs.length; i++) {
      var tumor_id = pairs[i][0];
       var normal_id = pairs[i][1];
       for(var j=0; j < pairs.length; j++) {
           for (var m=0; m < arrays.length; m++) {
               if (arrays[m][j]["basename"].indexOf(tumor_id) > -1) {
                   final_answers[m].push(arrays[m][j]);
               }
           }
       }
 final_answers[arrays.length+1].push(tumor_id);
 final_answers[arrays.length+2].push(normal_id);
 final_answers[arrays.length+3].push(inputs.vep_data[0]);
 final_answers[arrays.length+4].push(inputs.exac_filter[0]);
 final_answers[arrays.length+5].push(inputs.ref_fasta[0]);
 final_answers[arrays.length+6].push(inputs.vep_path[0]);
 final_answers[arrays.length+7].push(inputs.custom_enst[0]);
}
return {"tumor_id" : final_answers[arrays.length+1],
    "normal_id" : final_answers[arrays.length+2],
    "srt_combine_vcf" : final_answers[0],    
    "srt_genome": inputs.genome,
    "srt_ref_fasta":final_answers[arrays.length+5],
    "srt_vep_path":final_answers[arrays.length+6],
    "srt_custom_enst":final_answers[arrays.length+7],
    "srt_exac_filter": final_answers[arrays.length+4],
    "srt_vep_data": final_answers[arrays.length+3],
    "srt_bams": bams,
    "srt_hotspot_list": inputs.hotspot_list[0],
    "srt_curated_bams":inputs.curated_bams[0]};
}'
