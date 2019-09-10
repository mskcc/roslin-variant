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
  - class: foaf:Person
    foaf:name: Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org

cwlVersion: v1.0

class: Workflow
id: facets
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:

    normal_bam: File
    tumor_bam: File
    tumor_sample_name: string
    genome: string
    facets_pcval: int
    facets_cval: int
    facets_snps: string

outputs:

  facets_png_output:
    type: File[]
    outputSource: facets/png_files

  facets_txt_output_purity:
    type: File
    outputSource: facets/txt_files_purity

  facets_txt_output_hisens:
    type: File
    outputSource: facets/txt_files_hisens

  facets_out_output:
    type: File[]
    outputSource: facets/out_files

  facets_rdata_output:
    type: File[]
    outputSource: facets/rdata_files

  facets_seg_output:
    type: File[]
    outputSource: facets/seg_files

  facets_counts_output:
    type: File
    outputSource: snp_pileup/out_file

steps:
  snp_pileup:
    in:
      vcf: facets_snps
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
    run: ../../tools/htstools/0.1.1/snp-pileup.cwl

  facets:
    in:
      genome:
        default: "hg19"
      counts_file: snp_pileup/out_file
      TAG:
        valueFrom: ${ return inputs.counts_file.basename.replace(".dat.gz", ""); }
      directory:
        default: "."
      purity_cval: facets_pcval
      cval: facets_cval
      tumor_id: tumor_sample_name
    out: [png_files, txt_files_purity, txt_files_hisens, out_files, rdata_files, seg_files]
    run: ../../tools/facets.doFacets/1.6.2/facets.doFacets.cwl
