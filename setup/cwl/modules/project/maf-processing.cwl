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
  doap:name: maf-processing
  doap:revision: 1.0.0
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org
  - class: foaf:Person
    foaf:name: Nikhil Kumar
    foaf:mbox: mailto:kumarn1@mskcc.org

cwlVersion: v1.0

class: Workflow
id: maf-processing
requirements:
    MultipleInputFeatureRequirement: {}
    ScatterFeatureRequirement: {}
    SubworkflowFeatureRequirement: {}
    InlineJavascriptRequirement: {}
    StepInputExpressionRequirement: {}

inputs:
    db_files:
        type:
            type: record
            fields:
                pairing_file: File
                ref_fasta: string
                vep_path: string
                custom_enst: string
                vep_data: string
                hotspot_list: string
    runparams:
        type:
            type: record
            fields:
                genome: string
                tmp_dir: string
    pairs:
        type:
          type: array
          items:
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
    bams:
        type:
            type: array
            items:
                type: array
                items: File
        secondaryFiles:
            - ^.bai
    annotate_vcf: File[]
    exac_filter:
        type: File
        secondaryFiles:
            - .tbi
    curated_bams:
        type: File[]
        secondaryFiles:
            - ^.bai

outputs:

    maf:
        type: File[]
        outputSource: maf_processing_pair/maf
    portal_fillout:
        type: File[]
        outputSource: maf_processing_pair/portal_fillout

steps:
    maf_processing_pair:
        run: ../pair/maf-processing-pair.cwl
        in:
            runparams: runparams
            db_files: db_files
            bams: bams
            annotate_vcf: annotate_vcf
            pair: pairs
            genome:
                valueFrom: ${ return inputs.runparams.genome }
            ref_fasta:
                valueFrom: ${ return inputs.db_files.ref_fasta }
            vep_path:
                valueFrom: ${ return inputs.db_files.vep_path }
            custom_enst:
                valueFrom: ${ return inputs.db_files.custom_enst }
            exac_filter: exac_filter
            vep_data:
                valueFrom: ${ return inputs.db_files.vep_data }
            normal_sample_name:
                valueFrom: ${ var output = []; for (var i=0; i<inputs.pair.length; i++) { output=output.concat(inputs.pair[i][1].ID); } return output; }
            tumor_sample_name:
                valueFrom: ${ var output = []; for (var i=0; i<inputs.pair.length; i++) { output=output.concat(inputs.pair[i][0].ID); } return output; }
            curated_bams: curated_bams
            hotspot_list:
                valueFrom: ${ return inputs.db_files.hotspot_list }
            tmp_dir:
                valueFrom: ${ return inputs.runparams.tmp_dir }
            pairing_file:
                valueFrom: ${ return inputs.db_files.pairing_file }
        scatter: [pair, bams, annotate_vcf, normal_sample_name, tumor_sample_name]
        scatterMethod: dotproduct
        out: [maf,portal_fillout]