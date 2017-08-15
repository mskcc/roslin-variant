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
    genome: string

outputs:

  facets_png_output:
    type: File[]
    outputSource: facets/png_files

  facets_txt_output:
    type: File[]
    outputSource: facets/txt_files

  facets_out_output:
    type: File[]
    outputSource: facets/out_files

  facets_rdata_output:
    type: File[]
    outputSource: facets/rdata_files

  facets_seg_output:
    type: File[]
    outputSource: facets/seg_files

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
      vcf:
        default: "/ifs/work/pi/resources/facets/dbsnp_137.b37__RmDupsClean__plusPseudo50__DROP_SORT.vcf.gz"
      output_file:
        valueFrom: ${ return inputs.normal_bam.basename.replace(".ppfixed.bam", "") + "__" + inputs.tumor_bam.basename.replace(".ppfixed.bam", "") + ".dat.gz"; }
      normal_bam: ppflag_fixer/normal_ppfixed_bam
      tumor_bam: ppflag_fixer/tumor_ppfixed_bam
      count_orphans:
        valueFrom: ${ return true; }
      gzip:
        valueFrom: ${ return true; }
      pseudo_snps:
        default: "50"
    out: [out_file]
    run: cmo-snp-pileup/0.1.1/cmo-snp-pileup.cwl

  facets:
    in:
      genome:
        default: "hg19"
      counts_file: snp_pileup/out_file
      TAG:
        valueFrom: ${ return inputs.counts_file.basename.replace(".dat.gz", ""); }
      directory:
        default: "."
      purity_cval:
        default: 100
      cval:
        default: 50
    out: [png_files, txt_files, out_files, rdata_files, seg_files]
    run: cmo-facets.doFacets/1.5.5/cmo-facets.doFacets.cwl
