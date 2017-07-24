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
  doap:name: module-1.scatter.chunk
  doap:revision: 1.0.0
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Christopher Harris
    foaf:mbox: mailto:harrisc2@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Christopher Harris
    foaf:mbox: mailto:harrisc2@mskcc.org
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

inputs:

  fastq1: File[]
  fastq2: File[]
  adapter: string
  adapter2: string
  bwa_output: string
  add_rg_LB: string
  add_rg_PL: string
  add_rg_ID: string
  add_rg_PU: string
  add_rg_SM: string
  add_rg_CN: string
  tmp_dir: string
  genome: string
  group: string

outputs:

  clstats1:
    type:
      type: array
      items: File
    outputSource: align/clstats1
  clstats2:
    type:
      type: array
      items: File
    outputSource: align/clstats2
  bam:
    type: File
    outputSource: mark_duplicates/bam
  md_metrics:
    type: File
    outputSource: mark_duplicates/mdmetrics

steps:
  chunking:
    hints:
      ResourceRequirement:
        ramMin: 8
        coresMin: 2
    run: cmo-split-reads/1.0.0/cmo-split-reads.cwl
    in:
      fastq1: fastq1
      fastq2: fastq2
    out: [chunks1, chunks2]
    scatter: [fastq1, fastq2]
    scatterMethod: dotproduct
  flatten:
    run: flatten-array/1.0.0/flatten-array-fastq.cwl
    in:
      fastq1: chunking/chunks1
      fastq2: chunking/chunks2
    out:
      [chunks1, chunks2]
  align:
    in:
      chunkfastq1: flatten/chunks1
      chunkfastq2: flatten/chunks2
      adapter: adapter
      adapter2: adapter2
      genome: genome
      bwa_output: bwa_output
      add_rg_LB: add_rg_LB
      add_rg_PL: add_rg_PL
      add_rg_ID: add_rg_ID
      add_rg_PU: add_rg_PU
      add_rg_SM: add_rg_SM
      add_rg_CN: add_rg_CN
      tmp_dir: tmp_dir
    scatter: [chunkfastq1, chunkfastq2]
    scatterMethod: dotproduct
    out: [clstats1, clstats2, bam]
    run:
      class: Workflow
      inputs:
        chunkfastq1: File
        chunkfastq2: File
        adapter: string
        genome: string
        adapter2: string
        bwa_output: string
        add_rg_LB: string
        add_rg_PL: string
        add_rg_ID: string
        add_rg_PU: string
        add_rg_SM: string
        add_rg_CN: string
        tmp_dir: string
      outputs:
        clstats1:
          type:
            type: array
            items: File
          outputSource: trim_galore/clstats1
        clstats2:
          type:
            type: array
            items: File
          outputSource: trim_galore/clstats2
        bam:
          type:
             type: array
             items: File
          outputSource: add_rg_id/bam
      steps:
        trim_galore:
          run: ./cmo-trimgalore/0.2.5.mod/cmo-trimgalore.cwl
          in:
            fastq1: chunkfastq1
            fastq2: chunkfastq2
            adapter: adapter
            adapter2: adapter2
          out: [clfastq1, clfastq2, clstats1, clstats2]
        bwa:
          run: ./cmo-bwa-mem/0.7.5a/cmo-bwa-mem.cwl
          in:
            fastq1: trim_galore/clfastq1
            fastq2: trim_galore/clfastq2
            basebamname: bwa_output
            output:
              valueFrom: |
                ${ return inputs.basebamname.replace(".bam", "." + inputs.fastq1.basename.match(/chunk\d\d\d/)[0] + ".bam");}
            genome: genome
          out: [bam]
        add_rg_id:
          run: ./cmo-picard.AddOrReplaceReadGroups/1.96/cmo-picard.AddOrReplaceReadGroups.cwl
          in:
            I: bwa/bam
            O:
              valueFrom: |
                ${ return inputs.I.basename.replace(".bam", ".rg.bam") }
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
  mark_duplicates:
    run: ./cmo-picard.MarkDuplicates/1.96/cmo-picard.MarkDuplicates.cwl
    in:
      group: group
      I: align/bam
      O:
        valueFrom: |
          ${ return inputs.I[0].basename.replace(/\.chunk\d\d\d\.rg\.bam/, "."+ inputs.group+".rg.md.bam") }
      M:
        valueFrom: |
          ${ return inputs.I[0].basename.replace(/\.chunk\d\d\d\.rg\.bam/, ".rg.md_metrics") }
      TMP_DIR: tmp_dir
    out: [bam, bai, mdmetrics]
