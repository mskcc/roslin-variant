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
  doap:name: sample-workflow
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
id: sample-workflow
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}

inputs:

  sample:
    type:
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
  tmp_dir: string
  genome: string
  opt_dup_pix_dist: string
  bait_intervals: File
  target_intervals: File
  fp_intervals: File
  ref_fasta: string
  conpair_markers_bed: string
  gatk_jar_path: string

outputs:

  clstats1:
    type: File[]
    outputSource: align/clstats1
  clstats2:
    type: File[]
    outputSource: align/clstats2
  bam:
    type: File
    outputSource: mark_duplicates/bam
  md_metrics:
    type: File
    outputSource: mark_duplicates/mdmetrics
  as_metrics:
    type: File
    outputSource: flatten_group/as_metrics
  hs_metrics:
    type: File
    outputSource: flatten_group/hs_metrics
  insert_metrics:
    type: File
    outputSource: flatten_group/insert_metrics
  insert_pdf:
    type: File
    outputSource: flatten_group/insert_pdf
  per_target_coverage:
    type: File
    outputSource: flatten_group/per_target_coverage
  qual_metrics:
    type: File
    outputSource: flatten_group/qual_metrics
  qual_pdf:
    type: File
    outputSource: flatten_group/qual_pdf
  doc_basecounts:
    type: File
    outputSource: flatten_group/doc_basecounts
  gcbias_pdf:
    type: File
    outputSource: flatten_group/gcbias_pdf
  gcbias_metrics:
    type: File
    outputSource: flatten_group/gcbias_metrics
  gcbias_summary:
    type: File
    outputSource: flatten_group/gcbias_summary
  conpair_pileup:
    type: File
    outputSource: flatten_group/conpair_pileup
steps:
  chunking:
    run: ../cmo-split-reads/1.0.1/cmo-split-reads.cwl
    in:
      sample: sample
      fastq1:
        valueFrom: ${ return inputs.sample.R1 }
      fastq2:
        valueFrom: ${ return inputs.sample.R2 }
      platform_unit:
        valueFrom: ${ return inputs.sample.PU }
    out: [chunks1, chunks2]
    scatter: [fastq1, fastq2, platform_unit]
    scatterMethod: dotproduct
  flatten:
    run: ../flatten-array/1.0.0/flatten-array-fastq.cwl
    in:
      sample: sample
      fastq1: chunking/chunks1
      fastq2: chunking/chunks2
      add_rg_ID:
        valueFrom: ${ return inputs.sample.rg_ID }
      add_rg_PU:
        valueFrom: ${ return inputs.sample.PU }
    out:
      [chunks1, chunks2, rg_ID, rg_PU]
  align:
    in:
      chunkfastq1: flatten/chunks1
      chunkfastq2: flatten/chunks2
      sample: sample
      adapter:
        valueFrom: ${ return inputs.sample.adapter }
      adapter2:
        valueFrom: ${ return inputs.sample.adapter2 }
      genome: genome
      bwa_output:
        valueFrom: ${ return inputs.sample.bwa_output }
      add_rg_LB:
        valueFrom: ${ return inputs.sample.LB }
      add_rg_PL:
        valueFrom: ${ return inputs.sample.PL }
      add_rg_ID: flatten/rg_ID
      add_rg_PU: flatten/rg_PU
      add_rg_SM:
        valueFrom: ${ return inputs.sample.ID }
      add_rg_CN:
        valueFrom: ${ return inputs.sample.CN }
      tmp_dir: tmp_dir
    scatter: [chunkfastq1, chunkfastq2, add_rg_ID, add_rg_PU]
    scatterMethod: dotproduct
    out: [clstats1, clstats2, bam]
    run:
      class: Workflow
      id: alignment_sample
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
          type: File
          outputSource: trim_galore/clstats1
        clstats2:
          type: File
          outputSource: trim_galore/clstats2
        bam:
          type: File
          outputSource: add_rg_id/bam
      steps:
        trim_galore:
          run: ../cmo-trimgalore/0.2.5.mod/cmo-trimgalore.cwl
          in:
            fastq1: chunkfastq1
            fastq2: chunkfastq2
            adapter: adapter
            adapter2: adapter2
          out: [clfastq1, clfastq2, clstats1, clstats2]
        bwa:
          run: ../cmo-bwa-mem/0.7.5a/cmo-bwa-mem.cwl
          in:
            fastq1: trim_galore/clfastq1
            fastq2: trim_galore/clfastq2
            basebamname: bwa_output
            output:
              valueFrom: ${ return inputs.basebamname.replace(".bam", "." + inputs.fastq1.basename.match(/chunk\d\d\d/)[0] + ".bam");}
            genome: genome
          out: [bam]
        add_rg_id:
          run: ../cmo-picard.AddOrReplaceReadGroups/2.9/cmo-picard.AddOrReplaceReadGroups.cwl
          in:
            I: bwa/bam
            O:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".rg.bam") }
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
    run: ../cmo-picard.MarkDuplicates/2.9/cmo-picard.MarkDuplicates.cwl
    in:
      OPTICAL_DUPLICATE_PIXEL_DISTANCE: opt_dup_pix_dist
      I: align/bam
      O:
        valueFrom: ${ return inputs.I[0].basename.replace(/\.chunk\d\d\d\.rg\.bam/, ".rg.md.bam") }
      M:
        valueFrom: ${ return inputs.I[0].basename.replace(/\.chunk\d\d\d\.rg\.bam/, ".rg.md_metrics") }
      TMP_DIR: tmp_dir
    out: [bam, bai, mdmetrics]
  gather_metrics:
    run: gather-metrics.cwl
    in:
      bait_intervals: bait_intervals
      target_intervals: target_intervals
      fp_intervals: fp_intervals
      ref_fasta: ref_fasta
      conpair_markers_bed: conpair_markers_bed
      genome: genome
      tmp_dir: tmp_dir
      gatk_jar_path: gatk_jar_path
      single_bam: mark_duplicates/bam
      bams:
        valueFrom: ${ return [ inputs.single_bam ]; }
    out: [ as_metrics, hs_metrics, insert_metrics, insert_pdf, per_target_coverage, qual_metrics, qual_pdf, doc_basecounts, gcbias_pdf, gcbias_metrics, gcbias_summary, conpair_pileup ]
  flatten_group:
      in:
        as_metrics_inputs: gather_metrics/as_metrics
        hs_metrics_inputs: gather_metrics/hs_metrics
        insert_metrics_inputs: gather_metrics/insert_metrics
        insert_pdf_inputs: gather_metrics/insert_pdf
        per_target_coverage_inputs: gather_metrics/per_target_coverage
        qual_metrics_inputs: gather_metrics/qual_metrics
        qual_pdf_inputs: gather_metrics/qual_pdf
        doc_basecounts_inputs: gather_metrics/doc_basecounts
        gcbias_pdf_inputs: gather_metrics/gcbias_pdf
        gcbias_metrics_inputs: gather_metrics/gcbias_metrics
        gcbias_summary_inputs: gather_metrics/gcbias_summary
        conpair_pileup_inputs: gather_metrics/conpair_pileup
      out: [ as_metrics,hs_metrics,insert_metrics,insert_pdf,per_target_coverage,qual_metrics,qual_pdf,doc_basecounts,gcbias_pdf,gcbias_metrics,gcbias_summary,conpair_pileup]
      run:
          class: ExpressionTool
          id: flatten-group-sample
          requirements:
              - class: InlineJavascriptRequirement
          inputs:
            as_metrics_inputs: File[]
            hs_metrics_inputs: File[]
            insert_metrics_inputs: File[]
            insert_pdf_inputs: File[]
            per_target_coverage_inputs: File[]
            qual_metrics_inputs: File[]
            qual_pdf_inputs: File[]
            doc_basecounts_inputs: File[]
            gcbias_pdf_inputs: File[]
            gcbias_metrics_inputs: File[]
            gcbias_summary_inputs: File[]
            conpair_pileup_inputs: File[]
          outputs:
            as_metrics: File
            hs_metrics: File
            insert_metrics: File
            insert_pdf: File
            per_target_coverage: File
            qual_metrics: File
            qual_pdf: File
            doc_basecounts: File
            gcbias_pdf: File
            gcbias_metrics: File
            gcbias_summary: File
            conpair_pileup: File
          expression: "${ var output = {};
              for ( var input_key in inputs ){
                  new_key = input_key.slice(0,-7);
                  output[new_key] = inputs[input_key][0];
              }
              return output;
          }"