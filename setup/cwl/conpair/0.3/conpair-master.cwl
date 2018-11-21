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
  doap:name: conpair-master.cwl
  doap:revision: 0.2
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Zuojian Tang
    foaf:mbox: mailto:tangz@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Zuojian Tang
    foaf:mbox: mailto:tangz@mskcc.org

cwlVersion: cwl:v1.0

class: Workflow
id: conpair-master

requirements:
  InlineJavascriptRequirement: {}
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:

  ref:
    type:
    - [File, string]
    secondaryFiles:
      - ^.dict
      - ^.fasta.fai
  tumor_bams:
    type:
        type: array
        items: File
    secondaryFiles:
      - ^.bai
  normal_bams:
    type:
        type: array
        items: File
    secondaryFiles:
      - ^.bai
  normal_sample_name: string[]
  tumor_sample_name: string[]
  markers:
      type: 
      - [File, string]
  gatk_jar_path:
      type:
      - [File, string]
  markers_bed:
      type: 
      - [File, string]
  pairing_file:
      type: 
      - [File, string]
  file_prefix: string
  runparams:
    type:
      type: record
      fields:
        gatk_jar_path: string


outputs:

  concordance_txt:
      type: File
      outputSource: run-concordance/concordance_txt

  concordance_pdf:
      type: File
      outputSource: run-concordance/concordance_pdf

  contamination_txt:
      type: File
      outputSource: run-contaminations/contamination_txt

  contamination_pdf:
      type: File
      outputSource: run-contaminations/contamination_pdf

steps:
   run-pileups-contamination:
     in:
        tumor_bam: tumor_bams
        normal_bam: normal_bams
        tumor_sample_name: tumor_sample_name
        normal_sample_name: normal_sample_name
        ref: ref
        markers: markers
        markers_bed: markers_bed
        gatk_jar_path: gatk_jar_path
     out: [ tpileout, npileout, contam_out ]
     scatter: [ tumor_bam, normal_bam, tumor_sample_name, normal_sample_name ]
     scatterMethod: dotproduct
     run:
        class: Workflow
        inputs:
           tumor_bam: File
           normal_bam: File
           ref:
               type: File
               secondaryFiles:
                 - ^.dict
                 - ^.fasta.fai
           gatk_jar_path: string
           markers: string
           markers_bed: string
           tumor_sample_name: string
           normal_sample_name: string
        outputs:
           tpileout: 
                type: File
                outputSource: run-pileup-tumor/out_file
           npileout: 
                type: File
                outputSource: run-pileup-normal/out_file
           contam_out:
                type: File
                outputSource: contamination/out_file
        steps:
           run-pileup-tumor:
             run: conpair-pileup.cwl
             in:
                 bam: tumor_bam
                 ref: ref
                 gatk: gatk_jar_path
                 markers_bed: markers_bed
                 java_xmx:
                     valueFrom: ${ return ["24g"]; }
                 outfile:
                     valueFrom: ${ return inputs.bam.basename.replace(".bam", ".pileup"); }
             out: [out_file]

           run-pileup-normal:
             run: conpair-pileup.cwl
             in:
                 bam: normal_bam
                 ref: ref
                 gatk: gatk_jar_path
                 markers_bed: markers_bed
                 java_xmx:
                     valueFrom: ${ return ["24g"]; }
                 outfile:
                     valueFrom: ${ return inputs.bam.basename.replace(".bam", ".pileup"); }
             out: [out_file]

   run-contaminations:
     run: conpair-contaminations.cwl
     in:
        tpileup: pair-pileups/tpileup_ordered
        npileup: pair-pileups/npileup_ordered
        markers: markers
        pairing_file: pairing_file
        output_directory_name:
          valueFrom: ${ return "conpair_contaminations"; }
        output_prefix: file_prefix
     out: [ outdir ]

   run-concordance:
     run: conpair-concordances.cwl
     in:
        tpileup: pair-pileups/tpileup_ordered
        npileup: pair-pileups/npileup_ordered
        markers: markers
        pairing_file: pairing_file
        output_directory_name:
          valueFrom: ${ return "conpair_concordances"; }
        output_prefix: file_prefix
     out: [ outdir ]
