
#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- file:///ifs/work/pi/roslin-test/targeted-variants/326/roslin-core/2.0.5/schemas/dcterms.rdf
- file:///ifs/work/pi/roslin-test/targeted-variants/326/roslin-core/2.0.5/schemas/foaf.rdf
- file:///ifs/work/pi/roslin-test/targeted-variants/326/roslin-core/2.0.5/schemas/doap.rdf

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
    foaf:name: Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org

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
        refseq: File
        ref_fasta: string
        vep_data: string
        hotspot_list: File
        hotspot_vcf: File
        bait_intervals: File
        target_intervals: File
        fp_intervals: File
        fp_genotypes: File
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

  hs_metrics:
    type:
      type: array
      items: File

  per_target_coverage:
    type:
      type: array
      items: File

  as_metrics:
    type:
      type: array
      items: File

outputs:
  merged_mdmetrics:
    type: File
    outputSource: merge_mdmetrics/output

  merged_hsmetrics:
    type: File
    outputSource: merge_hsmetrics/output

  merged_hstmetrics:
    type: File
    outputSource: merge_hstmetrics/output

steps:

  merge_mdmetrics:
    in:
      runparams: runparams
      files: md_metrics
      outfile_name: 
        valueFrom: ${ return inputs.runparams.project_prefix + "_markDuplicatesMetrics.txt"; }
    out: [ output ]
    run: roslin-qc/merge-picard-metrics-markduplicates.cwl

  merge_hsmetrics:
    in:
      runparams: runparams
      files: hs_metrics
      outfile_name: 
        valueFrom: ${ return inputs.runparams.project_prefix + "_HsMetrics.txt"; }
    out: [ output ]
    run: roslin-qc/merge-picard-metrics-hsmetrics.cwl

  merge_hstmetrics:
    in:
      runparams: runparams
      files: per_target_coverage
      outfile_name:
        valueFrom: ${ return inputs.runparams.project_prefix + "_GcBiasMetrics.txt"; }
    out: [ output ]
    run: roslin-qc/merge-gcbias-metrics.cwl
