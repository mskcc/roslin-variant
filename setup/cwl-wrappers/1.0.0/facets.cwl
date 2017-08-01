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
    #fixme: add something

outputs:

    #fixme: add something

steps:

  ppflag_fixer:
    in:
      normal_bam: File
      tumor_bam: File
    out:
    run:
      class: Workflow
      inputs:
        normal_bam: File
        normal_bam: File
      outputs:
        normal_ppfixed_bam:
          type: File
          outputSource: normal_ppflag_fixer/outputBam
        tumor_ppfixed_bam:
          type: File
          outputSource: tumor_ppflag_fixer/outputBam
      steps:
        normal_ppflag_fixer:
          run: cmo-ppflag-fixer/0.1.1/cmo-ppflag-fixer.cwl
          in:
            inputBam: normal_bam
          out: [outputBam]
        tumor_ppflag_fixer:
          run: cmo-ppflag-fixer/0.1.1/cmo-ppflag-fixer.cwl
          in:
            inputBam: tumor_bam
          out: [outputBam]

  snp_pileup:
    in:
      normal_ppfixed_bam: ppflag_fixer/normal_ppfixed_bam
      tumor_ppfiex_bam: ppflag_fixer/tumor_ppfixed_bam
      #fixme: add something
    out:
      #fixme: add something
    run: cmo-snp-pileup/0.1.1/cmo-snp-pileup.cwl

  facets:
    in:
      #fixme: add something
    out:
      #fixme: add something
    run: facets/0.5.6/facets.cwl
