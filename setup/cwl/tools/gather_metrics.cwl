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
  doap:name: gather-metrics
  doap:revision: 1.0.0
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: C. Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org

cwlVersion: v1.0

class: Workflow
id: gather-metrics
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
        refseq: File
        ref_fasta: string
        vep_path: string
        custom_enst: string
        vep_data: string
        hotspot_list: string
        hotspot_list_maf: File
        hotspot_vcf: string
        facets_snps: string
        bait_intervals: File
        target_intervals: File
        fp_intervals: File
        fp_genotypes: File
        conpair_markers: string
        conpair_markers_bed: string
        grouping_file: File
        request_file: File
        pairing_file: File

  pairs:
    type:
      type: array
      items:
        type: array
        items: string

  runparams:
    type:
      type: record
      fields:
        abra_scratch: string
        covariates:
          type:
            type: array
            items: string
        emit_original_quals: boolean
        genome: string
        mutect_dcov: int
        mutect_rf:
          type:
            type: array
            items: string
        num_cpu_threads_per_data_thread: int
        num_threads: int
        tmp_dir: string
        project_prefix: string
        opt_dup_pix_dist: string
        facets_pcval: int
        facets_cval: int
        scripts_bin: string

  bams:
    type:
      type: array
      items:
        type: array
        items: File
    secondaryFiles: ^.bai

  clstats1:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: File

  clstats2:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: File

  md_metrics:
    type:
      type: array
      items:
        type: array
        items: File

outputs:

  as_metrics:
    type:
      type: array
      items: File
    outputSource: gather_metrics/as_metrics
  hs_metrics:
    type:
      type: array
      items: File
    outputSource: gather_metrics/hs_metrics
  insert_metrics:
    type:
      type: array
      items: File
    outputSource: gather_metrics/insert_metrics
  insert_pdf:
    type:
      type: array
      items: File
    outputSource: gather_metrics/is_hist
  per_target_coverage:
    type:
      type: array
      items: File
    outputSource: gather_metrics/per_target_coverage
  qual_metrics:
    type:
      type: array
      items: File
    outputSource: gather_metrics/qual_metrics
  qual_pdf:
    type:
      type: array
      items: File
    outputSource: gather_metrics/qual_pdf
  doc_basecounts:
    type:
      type: array
      items: File
    outputSource: gather_metrics/doc_basecounts
  gcbias_pdf:
    type:
      type: array
      items: File
    outputSource: gather_metrics/gcbias_pdf
  gcbias_metrics:
    type:
      type: array
      items: File
    outputSource: gather_metrics/gcbias_metrics
  gcbias_summary:
    type:
      type: array
      items: File
    outputSource: gather_metrics/gcbias_summary

  # qc
  gather_metrics_files:
    type: Directory
    outputSource: compile_intermediates_directory/directory

  qc_merged_and_hotspots_directory:
    type: Directory
    outputSource: qc_merge_and_hotspots/qc_merged_directory

steps:

  gather_metrics:
      in:
        bam: bams
        runparams: runparams
        db_files: db_files
        #bams:
        #  valueFrom: ${ return inputs.bams.flat(); }
        genome:
          valueFrom: ${ return inputs.runparams.genome; }
        bait_intervals:
          valueFrom: ${ return inputs.db_files.bait_intervals; }
        target_intervals:
          valueFrom: ${ return inputs.db_files.target_intervals; }
        fp_intervals:
          valueFrom: ${ return inputs.db_files.fp_intervals; }
        md_metrics_files: md_metrics
        clstats1: clstats1
        clstats2: clstats2
        tmp_dir:
          valueFrom: ${ return inputs.runparams.tmp_dir; }
      out: [as_metrics, hs_metrics, insert_metrics, per_target_coverage, qual_metrics, qual_pdf, is_hist, doc_basecounts, gcbias_pdf, gcbias_metrics, gcbias_summary]
      scatter: [bam]
      scatterMethod: dotproduct
      run:
        class: Workflow
        inputs:
          bam: File
          genome: string
          bait_intervals: File
          target_intervals: File
          fp_intervals: File
          tmp_dir: string
        outputs:
          gcbias_pdf:
            type: File
            outputSource: gcbias_metrics/pdf
          gcbias_metrics:
            type: File
            outputSource: gcbias_metrics/out_file
          gcbias_summary:
            type: File
            outputSource: gcbias_metrics/summary
          as_metrics:
            type: File
            outputSource: as_metrics/out_file
          hs_metrics:
            type: File
            outputSource: hs_metrics/out_file
          per_target_coverage:
            type: File
            outputSource: hst_metrics/per_target_out
          insert_metrics:
            type: File
            outputSource: insert_metrics/is_file
          is_hist:
            type: File
            outputSource: insert_metrics/is_hist
          qual_metrics:
            type: File
            outputSource: quality_metrics/qual_file
          qual_pdf:
            type: File
            outputSource: quality_metrics/qual_hist
          doc_basecounts:
            type: File
            outputSource: doc/out_file

        steps:
          as_metrics:
            run: cmo-picard.CollectAlignmentSummaryMetrics/2.9/cmo-picard.CollectAlignmentSummaryMetrics.cwl
            in:
              I: bam
              O:
                valueFrom: ${ return inputs.I.basename.replace(".bam", ".asmetrics")}
              LEVEL:
                valueFrom: ${return ["null", "SAMPLE"]}
              TMP_DIR: tmp_dir
            out: [out_file]

          hs_metrics:
            run: cmo-picard.CollectHsMetrics/2.9/cmo-picard.CollectHsMetrics.cwl
            in:
              BI: bait_intervals
              TI: target_intervals
              I: bam
              R: genome
              O:
                valueFrom: ${ return inputs.I.basename.replace(".bam", ".hsmetrics")}
              LEVEL:
                valueFrom: ${ return ["null", "SAMPLE"];}
              TMP_DIR: tmp_dir
            out: [out_file, per_target_out]

          hst_metrics:
            run: cmo-picard.CollectHsMetrics/2.9/cmo-picard.CollectHsMetrics.cwl
            in:
              BI: bait_intervals
              TI: target_intervals
              I: bam
              R: genome
              O:
                valueFrom: ${ return "all_reads_hsmerics_dump.txt"; }
              PER_TARGET_COVERAGE:
                valueFrom: ${ return inputs.I.basename.replace(".bam", ".hstmetrics")}
              LEVEL:
                valueFrom: ${ return ["ALL_READS"];}
              TMP_DIR: tmp_dir
            out: [per_target_out]

          insert_metrics:
            run: cmo-picard.CollectInsertSizeMetrics/2.9/cmo-picard.CollectInsertSizeMetrics.cwl
            in:
              I: bam
              H:
                valueFrom: ${ return inputs.I.basename.replace(".bam", ".ismetrics.pdf")}
              O:
                valueFrom: ${ return inputs.I.basename.replace(".bam", ".ismetrics")}
              LEVEL:
                valueFrom: ${ return ["null", "SAMPLE"];}
              TMP_DIR: tmp_dir
            out: [ is_file, is_hist]
          quality_metrics:
            run: cmo-picard.CollectMultipleMetrics/2.9/cmo-picard.CollectMultipleMetrics.cwl
            in:
              I: bam
              PROGRAM:
                valueFrom: ${return ["null","MeanQualityByCycle"]}
              O:
                valueFrom: ${ return inputs.I.basename.replace(".bam", ".qmetrics")}
              TMP_DIR: tmp_dir
            out: [qual_file, qual_hist]
          gcbias_metrics:
            run: cmo-picard.CollectGcBiasMetrics/2.9/cmo-picard.CollectGcBiasMetrics.cwl
            in:
              I: bam
              R: genome
              O:
                valueFrom: ${ return inputs.I.basename.replace(".bam", ".gcbiasmetrics") }
              CHART:
                valueFrom: ${ return inputs.I.basename.replace(".bam", ".gcbias.pdf")}
              S:
                valueFrom: ${ return inputs.I.basename.replace(".bam", ".gcbias.summary")}
              TMP_DIR: tmp_dir
            out: [pdf, out_file, summary]

          doc:
            run: cmo-gatk.DepthOfCoverage/3.3-0/cmo-gatk.DepthOfCoverage.cwl
            in:
              input_file: bam
              intervals: fp_intervals
              reference_sequence: genome
              out:
                valueFrom: ${ return inputs.input_file.basename.replace(".bam", "_FP_base_counts.txt") }
              omitLocustable:
                valueFrom: ${ return true; }
              omitPerSampleStats:
                valueFrom: ${ return true; }
              read_filter:
                valueFrom: ${ return ["BadCigar"];}
              minMappingQuality:
                valueFrom: ${ return "10"; }
              minBaseQuality:
                valueFrom: ${ return "3"; }
              omitIntervals:
                valueFrom: ${ return true; }
              printBaseCounts:
                valueFrom: ${ return true; }
              java_temp: tmp_dir
            out: [out_file]
  compile_intermediates_directory:
    run: ./consolidate-files/consolidate-files.cwl
    in:
      md_metrics: md_metrics
      data_files: [ gather_metrics/hs_metrics, gather_metrics/per_target_coverage, gather_metrics/insert_metrics, gather_metrics/doc_basecounts, gather_metrics/qual_metrics ]
      files:
        valueFrom: ${ return inputs.data_files.flat().concat(inputs.md_metrics.flat()); }
      output_directory_name:
        valueFrom: ${ return "gather_metrics_files"; }
    out: [ directory ]
  qc_merge_and_hotspots:
    run: ./roslin-qc/qc-merge-and-hotspots.cwl
    in:
      aa_bams: bams
      runparams: runparams
      db_files: db_files
      clstats1: clstats1
      clstats2: clstats2
      bams:
        valueFrom: ${ var output = [];  for (var i=0; i<inputs.aa_bams.length; i++) { output=output.concat(inputs.aa_bams[i]); } return output; }
      hs_metrics: gather_metrics/hs_metrics
      md_metrics: md_metrics
      per_target_coverage: gather_metrics/per_target_coverage
      insert_metrics: gather_metrics/insert_metrics
      doc_basecounts: gather_metrics/doc_basecounts
      qual_metrics: gather_metrics/qual_metrics
    out: [ qc_merged_directory ]
