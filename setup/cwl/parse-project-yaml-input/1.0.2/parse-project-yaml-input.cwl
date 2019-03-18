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
  doap:revision: 1.0.2
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
id: parse-project-yaml-input
requirements:
  - class: InlineJavascriptRequirement

inputs:
  db_files:
    type:
      type: record
      fields:
        bait_intervals: File
        refseq: File
        ref_fasta: string
        vep_path: string
        custom_enst: string
        vep_data: string
        hotspot_list: string
        hotspot_vcf: string
        target_intervals: File
        fp_intervals: File
        fp_genotypes: File
        grouping_file: File
        request_file: File
        pairing_file: File
        conpair_markers: string
        conpair_markers_bed: string
  hapmap_inputs:
    type: File
    secondaryFiles:
      - .idx
  dbsnp_inputs:
    type: File
    secondaryFiles:
      - .idx
  indels_1000g_inputs:
    type: File
    secondaryFiles:
      - .idx
  snps_1000g_inputs:
    type: File
    secondaryFiles:
      - .idx
  cosmic_inputs:
    type: File
    secondaryFiles:
      - .idx
  exac_filter_inputs:
    type: File
    secondaryFiles:
      - .tbi
  curated_bams_inputs:
    type:
      type: array
      items: File
    secondaryFiles:
      - ^.bai
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
        opt_dup_pix_dist: string
        facets_pcval: int
        facets_cval: int
        abra_ram_min: int
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
          PU: string[]
          R1: string[]
          R2: string[]
          RG_ID: string[]
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
          items: string
  R2:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: string
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
          items:
            type: array
            items: string
  PU:
    type:
      type: array
      items:
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
      items: int
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
      items:
        type: array
        items: string
  abra_ram_min:
    type:
      type: array
      items: int
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
  vep_path:
    type:
      type: array
      items: string
  custom_enst:
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
    secondaryFiles:
      - ^.bai
  hotspot_list:
    type:
      type: array
      items: string
  group_ids:
    type:
      type: array
      items: string
  fp_intervals: File
  genome: string
  project_prefix: string
  bait_intervals: File
  target_intervals: File
  fp_genotypes: File
  request_file: File
  conpair_markers: string
  conpair_markers_bed: string
  pairing_file: File
  hotspot_vcf: string
  grouping_file: File
  opt_dup_pix_dist: string
  ref_fasta_string: string

expression: "${var groups = inputs.groups;
                var samples = inputs.samples;
                var pairs = inputs.pairs;
                var project_object  = {};
for (var i =0; i < pairs.length; i++) {
     var pair_object = {};
     for (var j =0; j < pairs[i].length; j++) {
         for (var k=0; k < inputs.samples.length; k++) {
             if (pairs[i][j]==samples[k]['ID']) {
                 for (var key in samples[k]) {
                     if ( key in pair_object) {
                         pair_object[key].push(samples[k][key]);
                     } else {
                         pair_object[key]=[samples[k][key]];
                     }
                 }
             }
         }
         if (j==0) {
             var sample_name = pairs[i][j];
             for (var group_i =0; group_i < groups.length; group_i++) {
                  for (var group_j =0; group_j < groups[group_i].length; group_j++) {
                      if (sample_name == groups[group_i][group_j]){
                          pair_object['group_ids']='Pair' +i.toString() + 'Group' + group_i.toString();
                      }
                 }
             }
         }
     }
     var additional_db_files = ['hapmap_inputs', 'dbsnp_inputs', 'indels_1000g_inputs', 'snps_1000g_inputs', 'cosmic_inputs', 'exac_filter_inputs', 'curated_bams_inputs'];
     for (key in inputs.runparams) {
         pair_object[key] = inputs.runparams[key];
     } for (key in inputs.db_files) {
         pair_object[key] = inputs.db_files[key];
     }
     for ( var key_index in additional_db_files){
        var key = additional_db_files[key_index];
        var new_key = key.slice(0, -7);
        pair_object[new_key] = inputs[key];
      }
     pair_object['group_ids']='Group' + i.toString();
     for (key in pair_object) {
         if (key in project_object) {
             project_object[key].push(pair_object[key]);
         }
         else {
             project_object[key]=[pair_object[key]];
         }
     }
 }
project_object['bait_intervals']=inputs.db_files.bait_intervals;
project_object['target_intervals']=inputs.db_files.target_intervals;
project_object['fp_intervals']=inputs.db_files.fp_intervals;
project_object['fp_genotypes']=inputs.db_files.fp_genotypes;
project_object['conpair_markers']=inputs.db_files.conpair_markers;
project_object['conpair_markers_bed']=inputs.db_files.conpair_markers_bed;
project_object['request_file']=inputs.db_files.request_file;
project_object['pairing_file']=inputs.db_files.pairing_file;
project_object['hotspot_vcf']=inputs.db_files.hotspot_vcf;
project_object['grouping_file']=inputs.db_files.grouping_file;
project_object['ref_fasta_string']=inputs.db_files.ref_fasta;
project_object['genome']=inputs.runparams.genome;
project_object['project_prefix']=inputs.runparams.project_prefix;
project_object['opt_dup_pix_dist']=inputs.runparams.opt_dup_pix_dist;
return project_object;
}"
