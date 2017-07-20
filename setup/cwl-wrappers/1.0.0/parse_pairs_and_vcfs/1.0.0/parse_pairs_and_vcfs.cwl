#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: ExpressionTool
requirements:
  - class: InlineJavascriptRequirement

inputs:
  bams:
    type:
      type:  array
      items:
        type: array
        items: File
  genome: 
    type: 
      type: array
      items: string
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
  mutect_vcf:
    type:
      type: array
      items: File
  mutect_callstats:
    type:
      type: array
      items: File
  sid_vcf:
    type:
      type: array
      items: File
  sid_verbose:
    type:
      type: array
      items: File
  vardict_vcf:
    type:
      type: array
      items: File
  pindel_vcf:
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
  ffpe_normal_bams:
    type:
      type: array
      items:
        type: array
        items: File
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
  srt_mutect_vcf:
     type:
       type: array
       items: File
  srt_mutect_callstats:
     type:
       type: array
       items: File
  srt_sid_vcf:
     type:
       type: array
       items: File
  srt_sid_verbose:
     type:
       type: array
       items: File
  srt_vardict_vcf:
     type:
       type: array
       items: File
  srt_pindel_vcf:
     type:
       type: array
       items: File
  srt_ref_fasta:
     type:
       type: array
       items: string
  srt_genome:
     type:
       type: array
       items: string
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
  srt_ffpe_normal_bams:
     type:
       type: array
       items: File
  srt_hotspot_list: File


  

expression: '${var bams= [];
 for (var i=0; i< inputs.bams.length; i++) { 
     for (var j=0; j<inputs.bams[i].length; j++) { bams.push(inputs.bams[i][j]); 
     }
 } 
 var mutect_vcf = inputs.mutect_vcf;
 var mutect_callstats = inputs.mutect_callstats;
 var vardict_vcf = inputs.vardict_vcf;
 var sid_vcf = inputs.sid_vcf;
 var sid_verbose = inputs.sid_verbose;
 var pindel_vcf = inputs.pindel_vcf;
 var pairs = inputs.pairs;
 var arrays = [mutect_vcf, mutect_callstats, vardict_vcf, sid_vcf, sid_verbose, pindel_vcf];
 var final_answers = [];
 for (var m=0; m < arrays.length+7; m++) { 
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
 final_answers[arrays.length+4].push(inputs.genome[0]);
 final_answers[arrays.length+5].push(inputs.exac_filter[0]);
 final_answers[arrays.length+6].push(inputs.ref_fasta[0]);
} 
return {"tumor_id" : final_answers[arrays.length+1],
    "normal_id" : final_answers[arrays.length+2],
    "srt_mutect_vcf" : final_answers[0],
    "srt_mutect_callstats" : final_answers[1],
    "srt_vardict_vcf": final_answers[2],
    "srt_sid_vcf": final_answers[3],
    "srt_sid_verbose": final_answers[4], 
    "srt_pindel_vcf" : final_answers[5],
    "srt_genome": final_answers[arrays.length+4], 
    "srt_ref_fasta":final_answers[arrays.length+6],
    "srt_exac_filter": final_answers[arrays.length+5], 
    "srt_vep_data": final_answers[arrays.length+3], 
    "srt_bams": bams, 
    "srt_hotspot_list": inputs.hotspot_list[0],
    "srt_curated_bams":inputs.curated_bams[0],
    "srt_ffpe_normal_bams":inputs.ffpe_normal_bams[0]};
}'

