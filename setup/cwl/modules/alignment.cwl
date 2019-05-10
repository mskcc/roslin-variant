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
  doap:name: alignment
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
id: alignment
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}

inputs:

  db_files:
    type:
      type: record
      fields:
        ref_fasta: string
        bait_intervals: File
        target_intervals: File
        fp_intervals: File
        conpair_markers_bed: string
  hapmap:
    type: File
    secondaryFiles:
      - .idx
  dbsnp:
    type: File
    secondaryFiles:
      - .idx
  indels_1000g:
    type: File
    secondaryFiles:
      - .idx
  snps_1000g:
    type: File
    secondaryFiles:
      - .idx
  runparams:
    type:
      type: record
      fields:
        abra_scratch: string
        covariates: string[]
        genome: string
        intervals: string[]
        tmp_dir: string
        abra_ram_min: int
        gatk_jar_path: string
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

outputs:

  bams:
    type:
      type: array
      items:
        type: array
        items: File
    secondaryFiles:
      - ^.bai
    outputSource: alignment_pair/bams
  clstats1:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: File
    outputSource: alignment_pair/clstats1
  clstats2:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: File
    outputSource: alignment_pair/clstats2
  md_metrics:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: alignment_pair/md_metrics
  as_metrics:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: alignment_pair/as_metrics
  hs_metrics:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: alignment_pair/hs_metrics
  insert_metrics:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: alignment_pair/insert_metrics
  insert_pdf:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: alignment_pair/insert_pdf
  per_target_coverage:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: alignment_pair/per_target_coverage
  qual_metrics:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: alignment_pair/qual_metrics
  qual_pdf:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: alignment_pair/qual_pdf
  doc_basecounts:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: alignment_pair/doc_basecounts
  gcbias_pdf:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: alignment_pair/gcbias_pdf
  gcbias_metrics:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: alignment_pair/gcbias_metrics
  gcbias_summary:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: alignment_pair/gcbias_summary
  conpair_pileup:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: alignment_pair/conpair_pileup
  covint_list:
    type: File[]
    outputSource: alignment_pair/covint_list
  covint_bed:
    type: File[]
    outputSource: alignment_pair/covint_bed

steps:
  alignment_pair:
    in:
      runparams: runparams
      pair: pairs
      genome:
        valueFrom: ${ return inputs.runparams.genome }
      intervals:
        valueFrom: ${ return inputs.runparams.intervals }
      tmp_dir:
        valueFrom: ${ return inputs.runparams.tmp_dir }
      opt_dup_pix_dist:
        valueFrom: ${ return inputs.runparams.opt_dup_pix_dist }
      hapmap: hapmap
      dbsnp: dbsnp
      indels_1000g: indels_1000g
      snps_1000g: snps_1000g
      covariates:
        valueFrom: ${ return inputs.runparams.covariates }
      abra_scratch:
        valueFrom: ${ return inputs.runparams.abra_scratch }
      abra_ram_min:
        valueFrom: ${ return inputs.runparams.abra_ram_min }
      gatk_jar_path:
        valueFrom: ${ return inputs.runparams.gatk_jar_path }
      bait_intervals:
        valueFrom: ${ return inputs.db_files.bait_intervals }
      target_intervals:
        valueFrom: ${ return inputs.db_files.target_intervals }
      fp_intervals:
        valueFrom: ${ return inputs.db_files.fp_intervals }
      ref_fasta:
        valueFrom: ${ return inputs.db_files.ref_fasta }
      conpair_markers_bed:
        valueFrom: ${ return inputs.db_files.conpair_markers_bed }
    scatter: [pair]
    scatterMethod: dotproduct
    out: [bams,clstats1,clstats2,md_metrics,covint_list,covint_bed,as_metrics,hs_metrics,insert_metrics,insert_pdf,per_target_coverage,qual_metrics,qual_pdf,doc_basecounts,gcbias_pdf,gcbias_metrics,gcbias_summary,conpair_pileup]
    run:
      id: alignment-pair
      class: Workflow
      inputs:
          pair:
            type:
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
          genome: string
          intervals: string[]
          tmp_dir: string
          opt_dup_pix_dist: string
          hapmap:
            type: File
            secondaryFiles:
              - .idx
          dbsnp:
            type: File
            secondaryFiles:
              - .idx
          indels_1000g:
            type: File
            secondaryFiles:
              - .idx
          snps_1000g:
            type: File
            secondaryFiles:
              - .idx
          covariates: string[]
          abra_scratch: string
          abra_ram_min: int
          gatk_jar_path: string
          bait_intervals: File
          target_intervals: File
          fp_intervals: File
          ref_fasta: string
          conpair_markers_bed: string
      outputs:
        bams:
          type: File[]
          secondaryFiles:
            - ^.bai
          outputSource: realignment/outbams
        clstats1:
          type:
            type: array
            items:
              type: array
              items: File
          outputSource: sample_alignment/clstats1
        clstats2:
          type:
            type: array
            items:
              type: array
              items: File
          outputSource: sample_alignment/clstats2
        md_metrics:
          type: File[]
          outputSource: sample_alignment/md_metrics
        as_metrics:
          type: File[]
          outputSource: sample_alignment/as_metrics
        hs_metrics:
          type: File[]
          outputSource: sample_alignment/hs_metrics
        insert_metrics:
          type: File[]
          outputSource: sample_alignment/insert_metrics
        insert_pdf:
          type: File[]
          outputSource: sample_alignment/insert_pdf
        per_target_coverage:
          type: File[]
          outputSource: sample_alignment/per_target_coverage
        qual_metrics:
          type: File[]
          outputSource: sample_alignment/qual_metrics
        qual_pdf:
          type: File[]
          outputSource: sample_alignment/qual_pdf
        doc_basecounts:
          type: File[]
          outputSource: sample_alignment/doc_basecounts
        gcbias_pdf:
          type: File[]
          outputSource: sample_alignment/gcbias_pdf
        gcbias_metrics:
          type: File[]
          outputSource: sample_alignment/gcbias_metrics
        gcbias_summary:
          type: File[]
          outputSource: sample_alignment/gcbias_summary
        conpair_pileup:
          type: File[]
          outputSource: sample_alignment/conpair_pileup
        covint_list:
          type: File
          outputSource: realignment/covint_list
        covint_bed:
          type: File
          outputSource: realignment/covint_bed
      steps:
        sample_alignment:
          run: ../workflows/sample-workflow.cwl
          in:
            sample: pair
            genome: genome
            tmp_dir: tmp_dir
            opt_dup_pix_dist: opt_dup_pix_dist
            gatk_jar_path: gatk_jar_path
            bait_intervals: bait_intervals
            target_intervals: target_intervals
            fp_intervals: fp_intervals
            ref_fasta: ref_fasta
            conpair_markers_bed: conpair_markers_bed
          out: [clstats1,clstats2,bam,md_metrics,as_metrics,hs_metrics,insert_metrics,insert_pdf,per_target_coverage,qual_metrics,qual_pdf,doc_basecounts,gcbias_pdf,gcbias_metrics,gcbias_summary,conpair_pileup]
          scatter: [sample]
          scatterMethod: dotproduct
        realignment:
          run: ../modules/realignment.cwl
          in:
            pair: pair
            bams: sample_alignment/bam
            hapmap: hapmap
            dbsnp: dbsnp
            indels_1000g: indels_1000g
            snps_1000g: snps_1000g
            covariates: covariates
            abra_scratch: abra_scratch
            genome: genome
            intervals: intervals
            abra_ram_min: abra_ram_min
            tmp_dir: tmp_dir
          out: [outbams, covint_list, covint_bed]
