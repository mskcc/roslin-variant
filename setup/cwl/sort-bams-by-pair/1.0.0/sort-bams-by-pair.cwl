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
  doap:name: sort-bams-by-pair
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

  bams:
    type:
      type: array
      items:
        type: array
        items: File
  beds:
    type:
      type: array
      items: File
  pairs:
    type:
      type: array
      items:
        type: array
        items: string
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
        delly_type:
          type:
            type: array
            items: string
        ratiogeno: float
        altaf: float
        pass: boolean
        filter_somatic: string

outputs:

  covint_bed:
    type:
      type: array
      items: File
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
  cosmic:
    type:
      type: array
      items: File
  refseq:
    type:
      type: array
      items: File
  dbsnp:
    type:
      type: array
      items: File
  mutect_dcov:
    type:
      type: array
      items: string
  mutect_rf:
    type:
      type: array
      items:
        type: array
        items: string
  genome:
    type:
      type: array
      items: string
  delly_type:
    type:
      type: array
      items: 
        type:
          type: array
          items: string
  ratiogeno: 
    type: 
      type: array
      items: float
  altaf: 
    type:
      type: array
      items: float
  pass: 
    type:
      type: array
      items: boolean
  filter_somatic:
    type: 
      type: array
      items: string 

expression: '${
var samples = {};
var sample_beds =[];
var flattened_bams = [];
var extra_shit = {};
var keys_of_interest=["cosmic", "refseq", "dbsnp", "mutect_rf", "mutect_dcov", "genome", "ratiogeno", "altaf", "pass", "filter_somatic", "delly_type"];
for (var i = 0; i < inputs.bams.length; i++) {
    for (var j = 0; j < inputs.bams[i].length; j++) {
        flattened_bams.push(inputs.bams[i][j]);
    }
}
for (var i = 0; i < flattened_bams.length; i++) {
    var matches = flattened_bams[i].basename.match(/([^.]*)./);
    samples[matches[1]]=flattened_bams[i];
    for (var x=0; x< keys_of_interest.length; x++) {
        var key = keys_of_interest[x];
        if(key in inputs.runparams) {
            if (!(key in extra_shit)) {
                extra_shit[key]=[inputs.runparams[key]]
            }else{
                extra_shit[key].push(inputs.runparams[key]);
            }
        }
        if(key in inputs.db_files) {
            if (!(key in extra_shit)) {
                extra_shit[key]=[inputs.db_files[key]];
            }else{
                extra_shit[key].push(inputs.db_files[key]);
            }
        }
    }
}
var tumor_bams = [], tumor_sample_ids=[];
var normal_bams = [], normal_sample_ids=[];
for (var i=0; i < inputs.pairs.length; i++) {
    tumor_bams.push(samples[inputs.pairs[i][0]]);
    normal_bams.push(samples[inputs.pairs[i][1]]);
    tumor_sample_ids.push(inputs.pairs[i][0]);
    normal_sample_ids.push(inputs.pairs[i][1]);
    var tumor_group = samples[inputs.pairs[i][0]].basename.match(/Group\d+/)[0];
    for(var y = 0; y < inputs.beds.length; y++) {
        if (inputs.beds[y].basename.indexOf(tumor_group) > -1) {
            sample_beds.push(inputs.beds[y]);
        }
    }
}
var final_json= {"tumor_bams": tumor_bams, "normal_bams": normal_bams, "tumor_sample_ids": tumor_sample_ids, "normal_sample_ids": normal_sample_ids, "covint_bed": sample_beds};
for (var key in extra_shit) {
    final_json[key]=extra_shit[key];
}
return final_json;
}'
