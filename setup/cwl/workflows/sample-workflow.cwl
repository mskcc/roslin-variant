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
  StepInputExpressionRequirement: {}

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
        R1: File[]
        R2: File[]
        zR1: File[]
        zR2: File[]
        bam: File[]
        RG_ID: string[]
        adapter: string
        adapter2: string
        bwa_output: string
  ref_fasta:
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
      - ^.dict
  mouse_fasta:
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
      - ^.dict
  tmp_dir: string
  genome: string
  opt_dup_pix_dist: string
  bait_intervals: File
  target_intervals: File
  fp_intervals: File
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
    outputSource: gather_metrics/as_metrics
  hs_metrics:
    type: File
    outputSource: gather_metrics/hs_metrics
  insert_metrics:
    type: File
    outputSource: gather_metrics/insert_metrics
  insert_pdf:
    type: File
    outputSource: gather_metrics/insert_pdf
  per_target_coverage:
    type: File
    outputSource: gather_metrics/per_target_coverage
  doc_basecounts:
    type: File
    outputSource: gather_metrics/doc_basecounts
  gcbias_pdf:
    type: File
    outputSource: gather_metrics/gcbias_pdf
  gcbias_metrics:
    type: File
    outputSource: gather_metrics/gcbias_metrics
  gcbias_summary:
    type: File
    outputSource: gather_metrics/gcbias_summary
  conpair_pileup:
    type: File
    outputSource: gather_metrics/conpair_pileup
steps:
  get_sample_info:
      in:
        sample: sample
      out: [ CN,LB,ID,PL,PU,zPU,R1,R2,zR1,zR2,bam,RG_ID,adapter,adapter2,bwa_output]
      run:
          class: ExpressionTool
          id: get_sample_info
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
                  R1: File[]
                  R2: File[]
                  zR1: File[]
                  zR2: File[]
                  bam: File[]
                  RG_ID: string[]
                  adapter: string
                  adapter2: string
                  bwa_output: string
          outputs:
            CN: string
            LB: string
            ID: string
            PL: string
            PU: string[]
            zPU:
              type:
                type: array
                items:
                  type: array
                  items: string
            R1: File[]
            R2: File[]
            zR1: File[]
            zR2: File[]
            bam: File[]
            RG_ID: string[]
            adapter: string
            adapter2: string
            bwa_output: string
          expression: "${ var sample_object = {};
            for(var key in inputs.sample){
              sample_object[key] = inputs.sample[key]
            }
            sample_object['zPU'] = [];
            if(sample_object['zR1'].length != 0 && sample_object['zR2'].length != 0 ){
              sample_object['zPU'] = sample_object['PU'];
            }
            return sample_object;
          }"
  resolve_pdx:
    run: ../modules/sample/resolve-pdx.cwl
    in:
      human_reference: ref_fasta
      mouse_reference: mouse_fasta
      sample_id: get_sample_info/ID
      lane_id: get_sample_info/zPU
      r1: get_sample_info/zR1
      r2: get_sample_info/zR2
    out: [disambiguate_bam,summary]
    scatter: [lane_id]
    scatterMethod: dotproduct
  unpack_bam:
    run: ../tools/unpack-bam/0.1.0/unpack-bam.cwl
    in:
      input_bam:
        source: [resolve_pdx/disambiguate_bam, get_sample_info/bam]
        linkMerge: merge_flattened
      sample_id: get_sample_info/ID
    out: [rg_output]
    scatter: [input_bam]
    scatterMethod: dotproduct
  flatten_dir:
    run: ../tools/flatten-array/1.0.0/flatten-array-directory.cwl
    in:
      directory_list: unpack_bam/rg_output
    out: [output_directory]
  consolidate_reads:
    run: ../tools/consolidate-files/consolidate-reads.cwl
    in:
      reads_dir: flatten_dir/output_directory
    out: [r1,r2]
  chunking:
    run: ../tools/cmo-split-reads/1.0.1/cmo-split-reads.cwl
    in:
      fastq1:
        source: [get_sample_info/R1, consolidate_reads/r1]
        linkMerge: merge_flattened
      fastq2:
        source: [get_sample_info/R2, consolidate_reads/r2]
        linkMerge: merge_flattened
      platform_unit: get_sample_info/PU
    out: [chunks1, chunks2]
    scatter: [fastq1, fastq2, platform_unit]
    scatterMethod: dotproduct
  flatten:
    run: ../tools/flatten-array/1.0.0/flatten-array-fastq.cwl
    in:
      fastq1: chunking/chunks1
      fastq2: chunking/chunks2
      add_rg_ID: get_sample_info/RG_ID
      add_rg_PU: get_sample_info/PU
    out:
      [chunks1, chunks2, rg_ID, rg_PU]
  align:
    in:
      chunkfastq1: flatten/chunks1
      chunkfastq2: flatten/chunks2
      adapter: get_sample_info/adapter
      adapter2: get_sample_info/adapter2
      genome: genome
      bwa_output: get_sample_info/bwa_output
      add_rg_LB: get_sample_info/LB
      add_rg_PL: get_sample_info/PL
      add_rg_ID: flatten/rg_ID
      add_rg_PU: flatten/rg_PU
      add_rg_SM: get_sample_info/ID
      add_rg_CN: get_sample_info/CN
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
          run: ../tools/cmo-trimgalore/0.2.5.mod/cmo-trimgalore.cwl
          in:
            fastq1: chunkfastq1
            fastq2: chunkfastq2
            adapter: adapter
            adapter2: adapter2
          out: [clfastq1, clfastq2, clstats1, clstats2]
        bwa:
          run: ../tools/cmo-bwa-mem/0.7.5a/cmo-bwa-mem.cwl
          in:
            fastq1: trim_galore/clfastq1
            fastq2: trim_galore/clfastq2
            basebamname: bwa_output
            output:
              valueFrom: ${ return inputs.basebamname.replace(".bam", "." + inputs.fastq1.basename.match(/chunk\d\d\d/)[0] + ".bam");}
            genome: genome
          out: [bam]
        add_rg_id:
          run: ../tools/cmo-picard.AddOrReplaceReadGroups/2.9/cmo-picard.AddOrReplaceReadGroups.cwl
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
    run: ../tools/cmo-picard.MarkDuplicates/2.9/cmo-picard.MarkDuplicates.cwl
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
    run: ../modules/sample/gather-metrics-sample.cwl
    in:
      bait_intervals: bait_intervals
      target_intervals: target_intervals
      fp_intervals: fp_intervals
      ref_fasta: ref_fasta
      conpair_markers_bed: conpair_markers_bed
      genome: genome
      tmp_dir: tmp_dir
      gatk_jar_path: gatk_jar_path
      bam: mark_duplicates/bam
    out: [ gcbias_pdf,gcbias_metrics,gcbias_summary,as_metrics,hs_metrics,per_target_coverage,insert_metrics,insert_pdf,doc_basecounts,conpair_pileup ]