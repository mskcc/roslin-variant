#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- file:///ifs/work/pi/roslin-test/targeted-variants/237/roslin-core/2.0.0/schemas/dcterms.rdf
- file:///ifs/work/pi/roslin-test/targeted-variants/237/roslin-core/2.0.0/schemas/foaf.rdf
- file:///ifs/work/pi/roslin-test/targeted-variants/237/roslin-core/2.0.0/schemas/doap.rdf

doap:release:
- class: doap:Version
  doap:name: conpair-pileup.cwl
  doap:revision: 1.0.0
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

  normal_sample_name:
    type:
        type: array
        items: string

  tumor_sample_name:
    type:
        type: array
        items: string

  markers:
      type: 
      - [File, string]

  pairing_file:
      type: 
      - [File, string]

outputs:

  concordance_txt:
      type: File
      outputSource: run-merge-conpair/concordance_txt

  concordance_pdf:
      type: File
      outputSource: run-merge-conpair/concordance_pdf

  contamination_txt:
      type: File
      outputSource: run-merge-conpair/contamination_txt

  contamination_pdf:
      type: File
      outputSource: run-merge-conpair/contamination_pdf

steps:
   run-pileups-contamination:
     in:
        tumor_bam: tumor_bams
        normal_bam: normal_bams
        tumor_sample_name: tumor_sample_name
        normal_sample_name: normal_sample_name
        ref: ref
        markers: markers
     out: [ tpileout, npileout, contam_out ]
     scatter: [ tumor_bam, normal_bam, tumor_sample_name, normal_sample_name ]
     scatterMethod: dotproduct
     run:
        class: Workflow
        inputs:
           tumor_bam: 
              type: File
           normal_bam:
               type: File
           ref:
               type: File
               secondaryFiles:
                 - ^.dict
                 - ^.fasta.fai
           markers:
                type: File
           tumor_sample_name:
                type: string
           normal_sample_name:
                type: string
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
                 outfile:
                     valueFrom: ${ return inputs.bam.basename.replace(".bam", ".pileup"); }
             out: [out_file]

           run-pileup-normal:
             run: conpair-pileup.cwl
             in:
                 bam: normal_bam
                 ref: ref
                 outfile:
                     valueFrom: ${ return inputs.bam.basename.replace(".bam", ".pileup"); }
             out: [out_file]

           contamination:
             run: conpair-contamination.cwl
             in:
                 tpileup: run-pileup-tumor/out_file
                 npileup: run-pileup-normal/out_file
                 markers: markers
                 normal_sample_name: normal_sample_name
                 tumor_sample_name: tumor_sample_name
                 outfile:
                     valueFrom: ${ return inputs.tumor_sample_name + "." + inputs.normal_sample_name + ".contamination.txt"; }
             out: [out_file]

   pair-pileups:
     run: conpair-pileup-pairing.cwl
     in:
        tpileups: run-pileups-contamination/tpileout
        npileups: run-pileups-contamination/npileout
     out: [ tpileup_ordered, npileup_ordered ]

   run-concordance:
     in:
        tpileup: pair-pileups/tpileup_ordered
        npileup: pair-pileups/npileup_ordered
        markers: markers
     out: [ concordance_out ]
     scatter: [tpileup, npileup]
     scatterMethod: dotproduct
     run: 
        class: Workflow
        inputs:
            tpileup:
                type: File
            npileup:
                type: File
            markers:
                type: File
        outputs:
            concordance_out: 
                type: File
                outputSource: process-pileups/out_file
        steps:
            process-pileups:
               run: conpair-concordance.cwl
               in:
                 tpileup: tpileup
                 npileup: npileup
                 markers: markers
                 outfile:
                    valueFrom: ${ return inputs.tpileup.basename + "." + inputs.npileup.basename + ".concordance.txt"; }
               out: [out_file]

   run-merge-conpair:
     run: conpair-merge.cwl
     in:
       pairing_file: pairing_file
       cordlist: run-concordance/concordance_out
       tamilist: run-pileups-contamination/contam_out
     out: [ concordance_txt, concordance_pdf, contamination_txt, contamination_pdf ]