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
  doap:name: structural-variants
  doap:revision: 1.0.0
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org
  - class: foaf:Person
    foaf:name: Nikhil Kumar
    foaf:mbox: mailto:kumarn1@mskcc.org
  - class: foaf:Person
    foaf:name: Christopher Harris
    foaf:mbox: mailto:harrisc2@mskcc.org

cwlVersion: v1.0

class: Workflow
id: structural-variants
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
                ref_fasta: string
                vep_path: string
                custom_enst: string
                vep_data: string
    runparams:
        type:
            type: record
            fields:
                delly_type: string[]
                tmp_dir: string
                genome: string

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

outputs:

   delly_sv:
        type:
            type: array
            items:
                type: array
                items: File
        secondaryFiles:
            - ^.bcf.csi
        outputSource: structural_variants_pair/delly_sv
   delly_filtered_sv:
        type:
            type: array
            items:
                type: array
                items: File
        outputBinding:
            glob: '*.pass.bcf'
        secondaryFiles:
            - ^.bcf.csi
        outputSource: structural_variants_pair/delly_filtered_sv
   merged_file:
        type: File[]
        outputSource: structural_variants_pair/merged_file
   merged_file_unfiltered:
        type: File[]
        outputSource: structural_variants_pair/merged_file_unfiltered
   maf_file:
        type: File[]
        outputSource: structural_variants_pair/maf_file
   portal_file:
        type: File[]
        outputSource: structural_variants_pair/portal_file


steps:
    structural_variants_pair:
        run: ../pair/structural-variants-pair.cwl
        in:
            runparams: runparams
            db_files: db_files
            bams: bams
            pair: pairs
            normal_bam:
                valueFrom: ${ var output = []; for (var i=0; i<inputs.bams.length; i++) { output=output.concat(inputs.bams[i][1]); } return output; }
            tumor_bam:
                valueFrom: ${ var output = []; for (var i=0; i<inputs.bams.length; i++) { output=output.concat(inputs.bams[i][0]); } return output; }
            genome:
                valueFrom: ${ return inputs.runparams.genome }
            normal_sample_name:
                valueFrom: ${ var output = []; for (var i=0; i<inputs.pair.length; i++) { output=output.concat(inputs.pair[i][1].ID); } return output; }
            tumor_sample_name:
                valueFrom: ${ var output = []; for (var i=0; i<inputs.pair.length; i++) { output=output.concat(inputs.pair[i][0].ID); } return output; }
            ref_fasta:
                valueFrom: ${ return inputs.db_files.ref_fasta }
            vep_path:
                valueFrom: ${ return inputs.db_files.vep_path }
            custom_enst:
                valueFrom: ${ return inputs.db_files.custom_enst }
            vep_data:
                valueFrom: ${ return inputs.db_files.vep_data }
            delly_type:
                valueFrom: ${ return inputs.runparams.delly_type; }
            tmp_dir:
                valueFrom: ${ return inputs.runparams.tmp_dir; }
        scatter: [pair,normal_bam,tumor_bam,normal_sample_name,tumor_sample_name]
        scatterMethod: dotproduct
        out: [delly_sv,delly_filtered_sv,merged_file,merged_file_unfiltered,maf_file,portal_file]