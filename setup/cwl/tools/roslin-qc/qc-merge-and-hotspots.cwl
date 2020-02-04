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
  doap:name: qc-merge-and-hotspots
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
id: qc-merge-and-hotspots
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:

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
      items:
        type: array
        items: File

  insert_metrics:
    type:
      type: array
      items:
        type: array
        items: File

  per_target_coverage:
    type:
      type: array
      items:
        type: array
        items: File

  qual_metrics:
    type:
      type: array
      items:
        type: array
        items: File

  doc_basecounts:
    type:
      type: array
      items:
        type: array
        items: File
  project_prefix: string
  fp_genotypes: File
  grouping_file: File
  pairing_file: File
  hotspot_list_maf: File
  genome: string

outputs:

  merged_mdmetrics:
    type: File
    outputSource: qc_merge/merged_mdmetrics

  merged_hsmetrics:
    type: File
    outputSource: qc_merge/merged_hsmetrics

  merged_hstmetrics:
    type: File
    outputSource: qc_merge/merged_hstmetrics

  merged_insert_size_histograms:
    type: File
    outputSource: qc_merge/merged_insert_size_histograms

  fingerprints_output:
    type: File[]
    outputSource: qc_merge/fingerprints_output

  fingerprint_summary:
    type: File
    outputSource: qc_merge/fingerprint_summary

  qual_files_r:
    type: File
    outputSource: qc_merge/qual_files_r

  qual_files_o:
    type: File
    outputSource: qc_merge/qual_files_o
    
  hs_portal_fillout:
    type: File
    outputSource: hotspots_fillout/portal_fillout

  hs_in_normals:
    type: File?
    outputSource: run_hotspots_in_normals/hs_in_normals

  minor_contam_freqlist:
    type: File
    outputSource: run_minor_contam_binlist/minor_contam_freqlist

  qc_merged_directory:
    type: Directory
    outputSource: compiled_output_directory/directory

steps:

  qc_merge:
    run: qc-merge.cwl
    in:
      clstats1: clstats1
      clstats2: clstats2
      md_metrics: md_metrics
      hs_metrics: hs_metrics
      per_target_coverage: per_target_coverage
      insert_metrics: insert_metrics
      doc_basecounts: doc_basecounts
      qual_metrics: qual_metrics
      project_prefix: project_prefix
      fp_genotypes: fp_genotypes
      grouping_file: grouping_file
      pairing_file: pairing_file
    out: [ merged_mdmetrics, merged_hsmetrics, merged_hstmetrics, merged_insert_size_histograms, fingerprints_output, fingerprint_summary, minor_contam_output, qual_files_r, qual_files_o ]

  hotspots_fillout:
    run: ../cmo-fillout/1.2.2/cmo-fillout.cwl
    in:
      maf: hotspot_list_maf
      aa_bams: bams
      bams:
        valueFrom: ${ var output = [];  for (var i=0; i<inputs.aa_bams.length; i++) { output=output.concat(inputs.aa_bams[i]); } return output; }
      genome: genome
      output_format:
        valueFrom: ${ return "1"; }
      project_prefix: project_prefix
    out: [ portal_fillout ]

  run_hotspots_in_normals:
    run: create-hotspots-in-normals.cwl
    in:
      fillout_file: hotspots_fillout/portal_fillout
      project_prefix: project_prefix
      pairing_file: pairing_file
    out: [ hs_in_normals ]

  run_minor_contam_binlist:
    run: create-minor-contam-binlist.cwl
    in:
      minor_contam_file: qc_merge/minor_contam_output
      fp_summary: qc_merge/fingerprint_summary
      min_cutoff:
        default: 0.01
      project_prefix: project_prefix
    out: [ minor_contam_freqlist ]

  compiled_output_directory:
    run: ../consolidate-files/consolidate-files.cwl
    in:
      files:
        source: [ qc_merge/merged_mdmetrics, qc_merge/merged_hsmetrics, qc_merge/merged_hstmetrics, qc_merge/merged_insert_size_histograms, qc_merge/fingerprint_summary, qc_merge/minor_contam_output, qc_merge/qual_files_r, qc_merge/qual_files_o, run_hotspots_in_normals/hs_in_normals, run_minor_contam_binlist/minor_contam_freqlist, qc_merge/fingerprints_output ]
        linkMerge: merge_flattened
      output_directory_name:
        valueFrom: ${ return "qc_merged_directory"; }
    out: [ directory ]
