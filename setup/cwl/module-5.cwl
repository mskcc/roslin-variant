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
  doap:name: module-5
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
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:

  db_files:
    type:
      type: record
      fields:
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
        cosmic:
          type: File
          secondaryFiles:
            - .idx
        refseq: File
        ref_fasta: string
        vep_data: string
        exac_filter:
          type: File
          secondaryFiles:
            - .tbi
        hotspot_list: File
        hotspot_vcf: File
        curated_bams:
          type:
            type: array
            items: File
          secondaryFiles:
              - ^.bai
        bait_intervals: File
        target_intervals: File
        fp_intervals: File
        fp_genotypes: File
        conpair_markers: File
        conpair_markers_bed: File
        grouping_file: File
        request_file: File
        pairing_file: File
  bams:
    type:
      type: array
      items: File
    secondaryFiles: ^.bai
  genome: string
  bait_intervals: File
  target_intervals: File
  fp_intervals: File
  fp_genotypes: File
  grouping_file: File
  pairing_file: File
  request_file: File
  project_prefix: string
  md_metrics_files:
    type:
      type: array
      items:
        type: array
        items: File
  trim_metrics_files:
    type:
      type: array
      items:
        type: array
        items: File
  tumor_bams:
    type:
      type: array
      items: File
    secondaryFiles:
      - ^.bai
  normal_bams:
    type:
      type: array
      items: File
    secondaryFiles:
      - ^.bai
  tumor_sample_name:
    type:
      type: array
      items: string
  normal_sample_name:
    type:
      type: array
      items: string

outputs:

  as_metrics:
    type: File
    outputSource: scatter_metrics/as_metrics_files
  hs_metrics:
    type: File
    outputSource: scatter_metrics/hs_metrics_files
  insert_metrics:
    type: File
    outputSource: scatter_metrics/is_metrics
  insert_pdf:
    type: File
    outputSource: scatter_metrics/is_hist
  per_target_coverage:
    type: File
    outputSource: scatter_metrics/per_target_coverage
  qual_metrics:
    type: File
    outputSource: scatter_metrics/qual_metrics
  qual_pdf:
    type: File
    outputSource: scatter_metrics/qual_pdf
  doc_basecounts:
    type: File
    outputSource: scatter_metrics/doc_basecounts
  gcbias_pdf:
    type: File
    outputSource: scatter_metrics/gcbias_pdf
  gcbias_metrics:
    type: File
    outputSource: scatter_metrics/gcbias_metrics_files
  gcbias_summary:
    type: File
    outputSource: scatter_metrics/gcbias_summary
  qc_files:
    type: File
    outputSource: generate_pdf/qc_files
  concordance_txt:
    type: File
    outputSource: run-conpair/concordance_txt
  concordance_pdf:
    type: File
    outputSource: run-conpair/concordance_pdf
  contamination_txt:
    type: File
    outputSource: run-conpair/contamination_txt
  contamination_pdf:
    type: File
    outputSource: run-conpair/contamination_pdf

steps:

  scatter_metrics:
    in:
      bam: bams
      genome: genome
      bait_intervals: bait_intervals
      target_intervals: target_intervals
      fp_intervals: fp_intervals
    out: [as_metrics_files, hs_metrics_files, is_metrics, per_target_coverage, qual_metrics, qual_pdf, is_hist, doc_basecounts, gcbias_pdf, gcbias_metrics_files, gcbias_summary]
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
      outputs:
        gcbias_pdf:
          type: File
          outputSource: gcbias_metrics/pdf
        gcbias_metrics_files:
          type: File
          outputSource: gcbias_metrics/out_file
        gcbias_summary:
          type: File
          outputSource: gcbias_metrics/summary

        as_metrics_files:
          type: File
          outputSource: as_metrics/out_file
        hs_metrics_files:
          type: File
          outputSource: hs_metrics/out_file
        per_target_coverage:
          type: File
          outputSource: hs_metrics/per_target_out
        is_metrics:
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
            PER_TARGET_COVERAGE:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".hstmetrics")}
            LEVEL:
              valueFrom: ${ return ["null", "SAMPLE"];}
          out: [out_file, per_target_out]
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
          out: [ is_file, is_hist]
        quality_metrics:
          run: cmo-picard.CollectMultipleMetrics/2.9/cmo-picard.CollectMultipleMetrics.cwl
          in:
            I: bam
            PROGRAM:
              valueFrom: ${return ["null","MeanQualityByCycle"]}
            O:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".qmetrics")}
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
          out: [out_file]

  run-conpair:
    run: conpair/0.2/conpair-master.cwl
    in:
      db_files: db_files
      ref:
        valueFrom: ${ return inputs.db_files.ref_fasta; }
      markers: 
        valueFrom: ${ return inputs.db_files.conpair_markers; }
      markers_bed: 
        valueFrom: ${ return inputs.db_files.conpair_markers_bed; }
      tumor_bams: tumor_bams
      normal_bams: normal_bams
      tumor_sample_name: tumor_sample_name
      normal_sample_name: normal_sample_name
      file_prefix: project_prefix
      pairing_file:
        valueFrom: ${ return inputs.db_files.pairing_file; }
    out: [ concordance_txt, concordance_pdf, contamination_txt, contamination_pdf ]

  generate_pdf:
    run: cmo-qcpdf/0.5.10/cmo-qcpdf.cwl
    in:
      files: scatter_metrics/as_metrics_files
      md_metrics_files: md_metrics_files
      trim_metrics_files: trim_metrics_files
      gcbias_files:
        valueFrom: ${ return "*.gcbiasmetrics";}
      mdmetrics_files:
        valueFrom: ${ return "*.md_metrics";}
      fingerprint_files:
        valueFrom: ${ return "*_FP_base_counts.txt";}
      trimgalore_files:
        valueFrom: ${ return "*_cl.stats";}
      insertsize_files:
        valueFrom: ${ return "*.ismetrics";}
      hsmetrics_files:
        valueFrom: ${ return "*.hsmetrics";}
      qualmetrics_files:
        valueFrom: ${ return "*.quality_by_cycle_metrics";}
      file_prefix: project_prefix
      fp_genotypes: fp_genotypes
      pairing_file: pairing_file
      grouping_file: grouping_file
      request_file: request_file
    out: [qc_files]
