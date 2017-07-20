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
  doap:name: parse-project-yaml-input
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
requirements:
  - class: InlineJavascriptRequirement

inputs:
  db_files:
    type:
      type: record
      fields:
        cosmic: File
        dbsnp: File
        hapmap: File
        indels_1000g: File
        refseq: File
        snps_1000g: File
        ref_fasta: string
        exac_filter: File
        vep_data: string
  groups:
    type:
      type: array
      items:
        type: array
        items: string
  runparams:
    type:
      type: record
      fields:
        abra_scratch: string
        covariates:
          type:
            type: array
            items: string
        emit_original_quals: boolean
        genome: string
        mutect_dcov: int
        mutect_rf:
          type:
            type: array
            items: string
        num_cpu_threads_per_data_thread: int
        num_threads: int
        tmp_dir: string
  samples:
    type:
      type: array
      items:
        type: record
        fields:
          CN: string
          LB: string
          ID: string
          PL: string
          PU: string
          R1:
            type:
              type: array
              items: File
          R2:
            type:
              type: array
              items: File
          RG_ID: string
          adapter: string
          adapter2: string
          bwa_output: string
  pairs:
    type:
      type: array
      items:
        type: array
        items: string
outputs:
  R1:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: File
  R2:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: File
  adapter:
    type:
      type: array
      items:
        type: array
        items: string
  adapter2:
    type:
      type: array
      items:
        type: array
        items: string
  LB:
    type:
      type: array
      items:
        type: array
        items: string
  PL:
    type:
      type: array
      items:
        type: array
        items: string
  RG_ID:
    type:
      type: array
      items:
        type: array
        items: string
  PU:
    type:
      type: array
      items:
        type: array
        items: string
  ID:
    type:
      type: array
      items:
        type: array
        items: string
  CN:
    type:
      type: array
      items:
        type: array
        items: string
  bwa_output:
    type:
      type: array
      items:
        type: array
        items: string
  tmp_dir:
    type:
      type: array
      items:
        type: array
        items: string
  covariates:
    type:
      type: array
      items:
        type: array
        items: string
  mutect_rf:
    type:
      type: array
      items:
        type: array
        items: string
  mutect_dcov:
    type:
      type: array
      items: string
  num_cpu_threads_per_data_thread:
    type:
      type: array
      items: string
  num_threads:
    type:
      type: array
      items: string
  abra_scratch:
    type:
      type: array
      items: string
  genome:
    type:
      type: array
      items: string
  dbsnp:
    type:
      type: array
      items: File
  snps_1000g:
    type:
      type: array
      items: File
  indels_1000g:
    type:
      type: array
      items: File
  hapmap:
    type:
      type: array
      items: File
  cosmic:
    type:
      type: array
      items: File
  refseq:
    type:
      type: array
      items: File
  exac_filter:
    type:
      type: array
      items: File
  ref_fasta:
    type:
      type: array
      items: string
  vep_data:
    type:
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



expression: "${var groups = inputs.groups;
                var samples = inputs.samples;
                var pairs = inputs.pairs;
                var project_object  = {};
 for (var i =0; i < groups.length; i++) { 
     var group_object = {};
     for (var j =0; j < groups[i].length; j++) {
         for (var k=0; k < inputs.samples.length; k++) { 
             if (groups[i][j]==samples[k]['ID']) { 
                 for (var key in samples[k]) { 
                     if ( key in group_object) { 
                         group_object[key].push(samples[k][key]) 
                     } else { 
                         group_object[key]=[samples[k][key]] 
                     } 
                 } 
             } 
         } 
     }
     for (key in inputs.runparams) { 
         group_object[key] = inputs.runparams[key] 
     } for (key in inputs.db_files) {
         group_object[key] = inputs.db_files[key] 
     }  
     for (key in group_object) { 
         if (key in project_object) { 
             project_object[key].push(group_object[key])
         }
         else { 
             project_object[key]=[group_object[key]]
         }
     }
 }
return project_object;
}"

