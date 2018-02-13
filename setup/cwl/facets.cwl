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
  snp_pileup:
    in:
      vcf:
        default: "/ifs/work/pi/resources/facets/dbsnp_137.b37__RmDupsClean__plusPseudo50__DROP_SORT.vcf.gz"
      output_file:
        valueFrom: ${ return inputs.normal_bam.basename.replace(".bam", "") + "__" + inputs.tumor_bam.basename.replace(".bam", "") + ".dat.gz"; }
      normal_bam: normal_bam
      tumor_bam: tumor_bam
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
        default: 500
      cval:
        default: 100
    out: [png_files, txt_files, out_files, rdata_files, seg_files]
    run: cmo-facets.doFacets/1.5.5/cmo-facets.doFacets.cwl
