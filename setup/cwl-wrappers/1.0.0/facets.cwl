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
  doap:name: facets
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

cwlVersion: v1.0

class: Workflow
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:

    normal_bam: File
    tumor_bam: File
    vcf: File
    pseudo_snps: string
    genome: string
    purity_cval: string
    cval: string

outputs:

  ppflag_fixer_output:
    type: File
    outputSource: ppflag_fixer/normal_ppfixed_bam

#  facets_output:
#    type: File
#    outputSource: facets/

steps:

  ppflag_fixer:
    in:
      normal_bam: normal_bam
      tumor_bam: tumor_bam
    out: [normal_ppfixed_bam, tumor_ppfixed_bam]
    run:
      class: Workflow
      inputs:
        normal_bam: File
        tumor_bam: File
      outputs:
        normal_ppfixed_bam:
          type: File
          outputSource: normal_ppflag_fixer/out_file
        tumor_ppfixed_bam:
          type: File
          outputSource: tumor_ppflag_fixer/out_file
      steps:
        normal_ppflag_fixer:
          run: cmo-ppflag-fixer/0.1.1/cmo-ppflag-fixer.cwl
          in:
            input_file: normal_bam
            output_file:
              valueFrom: ${ return inputs.input_file.basename.replace(".bam", ".ppfixed.bam"); }
          out: [out_file]
        tumor_ppflag_fixer:
          run: cmo-ppflag-fixer/0.1.1/cmo-ppflag-fixer.cwl
          in:
            input_file: tumor_bam
            output_file:
              valueFrom: ${ return inputs.input_file.basename.replace(".bam", ".ppfixed.bam"); }
          out: [out_file]

  snp_pileup:
    in:
      vcf: vcf
      output_file:
        valueFrom: ${ return inputs.normal_bam.basename.replace(".ppfixed.bam", "") + "__" + inputs.tumor_bam.basename.replace(".ppfixed.bam", "") + ".dat.gz"; }
      normal_bam: ppflag_fixer/normal_ppfixed_bam
      tumor_bam: ppflag_fixer/tumor_ppfixed_bam
      count_orphans:
        default: true
      gzip:
        default: true
      pseudo_snps: pseudo_snps
    out: [out_file]
    run: cmo-snp-pileup/0.1.1/cmo-snp-pileup.cwl

  facets:
    in:
      genome: genome
      counts_file: snp_pileup/out_file
      TAG:
        valueFrom: ${ return inputs.counts_file.basename.replace(".dat.gz", ""); }
      directory:
        default: "."
      purity_cval: purity_cval
      cval: cval
      R_lib:
        default: "0.5.6"
    out: []
    run: cmo-facets.doFacets/1.5.4/cmo-facets.doFacets.cwl
