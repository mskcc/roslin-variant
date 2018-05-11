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
  doap:name: module-1
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
    foaf:name: Christopher Harris
    foaf:mbox: mailto:harrisc2@mskcc.org
  - class: foaf:Person
    foaf:name: Ronak H. Shah
    foaf:mbox: mailto:shahr2@mskcc.org
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

cwlVersion: v1.0

class: Workflow
requirements:
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}

inputs:

  adapter: string
  adapter2: string
  fastq1: File
  fastq2: File

  genome: string
  bwa_output: string

  add_rg_LB: string
  add_rg_PL: string
  add_rg_ID: string
  add_rg_PU: string
  add_rg_SM: string
  add_rg_CN: string
  add_rg_output: string

  md_output: string
  md_metrics_output: string

  tmp_dir: string

steps:

    cmo-trimgalore:
        run: ./cmo-trimgalore/0.2.5.mod/cmo-trimgalore.cwl
        in:
          adapter: adapter
          adapter2: adapter2
          fastq1: fastq1
          fastq2: fastq2
        out: [clfastq1,clfastq2,clstats1,clstats2]

    cmo-bwa-mem:
        run: ./cmo-bwa-mem/0.7.5a/cmo-bwa-mem.cwl
        in:
          fastq1: cmo-trimgalore/clfastq1
          fastq2: cmo-trimgalore/clfastq2
          genome: genome
          output: bwa_output
        out: [bam]

    cmo-picard.AddOrReplaceReadGroups:
        run: ./cmo-picard.AddOrReplaceReadGroups/2.9/cmo-picard.AddOrReplaceReadGroups.cwl
        in:
          I: cmo-bwa-mem/bam
          O: add_rg_output
          LB: add_rg_LB
          PL: add_rg_PL
          ID: add_rg_ID
          PU: add_rg_PU
          SM: add_rg_SM
          CN: add_rg_CN
          SO:
            default: "coordinate"
          TMP_DIR: tmp_dir
        out: [bam, bai]

    cmo-picard.MarkDuplicates:
        run: ./cmo-picard.MarkDuplicates/2.9/cmo-picard.MarkDuplicates.cwl
        in:
          I:
            source: cmo-picard.AddOrReplaceReadGroups/bam
            valueFrom: ${ return [self]; }
          O: md_output
          M: md_metrics_output
          TMP_DIR: tmp_dir
        out: [bam,bai,mdmetrics]

outputs:

  clstats1:
    type: File
    outputSource: cmo-trimgalore/clstats1

  clstats2:
    type: File
    outputSource: cmo-trimgalore/clstats2

  bam:
    type: File
    outputSource: cmo-picard.MarkDuplicates/bam

  bai:
    type: File
    outputSource: cmo-picard.MarkDuplicates/bai

  md_metrics:
    type: File
    outputSource: cmo-picard.MarkDuplicates/mdmetrics
