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
  doap:name: generate-qc
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
id: generate-qc
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:

  db_files:
    type:
      type: record
      fields:
        fp_genotypes: File
        grouping_file: File
        pairing_file: File
        hotspot_list_maf: File
        conpair_markers: string
  runparams:
    type:
      type: record
      fields:
        project_prefix: string
        genome: string
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
  conpair_pileups:
    type:
      type: array
      items:
        type: array
        items: File
  directories:
    type:
      type: array
      items: Directory
    default: []
  files:
    type:
      type: array
      items: File
    default: []


outputs:

  # qc
  consolidated_results:
    type: Directory
    outputSource: consolidate_results/directory
  qc_pdf:
    type: File
    outputSource: generate_qc/qc_pdf

steps:
  pair-pileups:
    run: ../../tools/conpair/0.3.1/conpair-pileup-pairing.cwl
    in:
      pileups: conpair_pileups
      npileups:
        valueFrom: ${ var output = []; for (var i=0; i<inputs.pileups.length; i++) { output=output.concat(inputs.pileups[i][0]); } return output; }
      tpileups:
        valueFrom: ${ var output = []; for (var i=0; i<inputs.pileups.length; i++) { output=output.concat(inputs.pileups[i][1]); } return output; }
    out: [ tpileup_ordered, npileup_ordered ]
  run-contamination:
    run: ../../tools/conpair/0.3.1/conpair-contaminations.cwl
    in:
      runparams: runparams
      db_files: db_files
      tpileup: pair-pileups/tpileup_ordered
      npileup: pair-pileups/npileup_ordered
      markers:
        valueFrom: ${ return inputs.db_files.conpair_markers; }
      pairing_file:
        valueFrom: ${ return inputs.db_files.pairing_file }
      output_prefix:
        valueFrom: ${ return inputs.runparams.project_prefix; }
    out: [ outfiles, pdf ]

  run-concordance:
    run: ../../tools/conpair/0.3.1/conpair-concordances.cwl
    in:
      tpileup: pair-pileups/tpileup_ordered
      npileup: pair-pileups/npileup_ordered
      markers:
        valueFrom: ${ return inputs.db_files.conpair_markers; }
      pairing_file:
        valueFrom: ${ return inputs.db_files.pairing_file; }
      output_prefix:
        valueFrom: ${ return inputs.runparams.project_prefix; }
    out: [ outfiles, pdf ]

  put-conpair-files-into-directory:
    run: ../../tools/conpair/0.3.1/consolidate-conpair-files.cwl
    in:
      concordance_files: run-concordance/outfiles
      contamination_files: run-contamination/outfiles
      files:
        valueFrom: ${ return inputs.concordance_files.concat(inputs.contamination_files); }
      output_directory_name:
        valueFrom: ${ return "conpair_output_files"; }
    out: [ directory ]

  qc_merge_and_hotspots:
    run: ../../tools/roslin-qc/qc-merge-and-hotspots.cwl
    in:
      aa_bams: bams
      runparams: runparams
      db_files: db_files
      clstats1: clstats1
      clstats2: clstats2
      bams:
        valueFrom: ${ var output = [];  for (var i=0; i<inputs.aa_bams.length; i++) { output=output.concat(inputs.aa_bams[i]); } return output; }
      hs_metrics: hs_metrics
      md_metrics: md_metrics
      per_target_coverage: per_target_coverage
      insert_metrics: insert_metrics
      doc_basecounts: doc_basecounts
      qual_metrics: qual_metrics
      project_prefix:
        valueFrom: ${ return inputs.runparams.project_prefix; }
      fp_genotypes:
        valueFrom: ${ return inputs.db_files.fp_genotypes }
      grouping_file:
        valueFrom: ${ return inputs.db_files.grouping_file }
      pairing_file:
        valueFrom: ${ return inputs.db_files.pairing_file }
      hotspot_list_maf:
        valueFrom: ${ return inputs.db_files.hotspot_list_maf }
      genome:
        valueFrom: ${ return inputs.runparams.genome; }
    out: [ qc_merged_directory ]
  generate_images:
    run: ../../tools/roslin-qc/generate-images.cwl
    in:
      runparams: runparams
      db_files: db_files
      data_dir:  qc_merge_and_hotspots/qc_merged_directory
      bin:
        valueFrom: ${ return inputs.runparams.scripts_bin; }
      file_prefix:
        valueFrom: ${ return inputs.runparams.project_prefix; }
    out: [ output, images_directory, project_summary, sample_summary ]
  consolidate_results:
    run: ../../tools/consolidate-files/consolidate-files-mixed.cwl
    in:
      output_directory_name:
        valueFrom: ${ return "consolidated_metrics_data"; }
      input_directories: directories
      conpair_directory: put-conpair-files-into-directory/directory
      qc_merged_and_hotspots_directory: qc_merge_and_hotspots/qc_merged_directory
      generate_images_directory: generate_images/output
      files: files
      directories:
        valueFrom: ${ var metrics_data = [inputs.qc_merged_and_hotspots_directory, inputs.generate_images_directory, inputs.conpair_directory ]; return metrics_data.concat(inputs.input_directories); }
    out: [ directory ]
  generate_qc:
    run: ../../tools/roslin-qc/genlatex.cwl
    in:
      runparams: runparams
      data_dir: consolidate_results/directory
      project_prefix:
        valueFrom: ${ return inputs.runparams.project_prefix; }
    out: [ qc_pdf ]