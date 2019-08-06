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
  doap:name: pair-workflow-sv
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
  - class: foaf:Person
    foaf:name: Nikhil Kumar
    foaf:mbox: mailto:kumarn1@mskcc.org
  - class: foaf:Person
    foaf:name: Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org


cwlVersion: v1.0

class: Workflow
id: pair-workflow-sv
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
        vep_path: string
        custom_enst: string
        vep_data: string
        hotspot_list: string
        hotspot_list_maf: File
        delly_exclude: File
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
  exac_filter:
    type: File
    secondaryFiles:
      - .tbi
  curated_bams:
    type:
      type: array
      items: File
    secondaryFiles:
      - ^.bai
  runparams:
    type:
      type: record
      fields:
        abra_scratch: string
        covariates: string[]
        emit_original_quals: boolean
        genome: string
        intervals: string[]
        mutect_dcov: int
        mutect_rf: string[]
        num_cpu_threads_per_data_thread: int
        num_threads: int
        tmp_dir: string
        complex_tn: float
        complex_nn: float
        delly_type: string[]
        project_prefix: string
        opt_dup_pix_dist: string
        facets_pcval: int
        facets_cval: int
        abra_ram_min: int
        scripts_bin: string
        gatk_jar_path: string
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
          R1: File[]
          R2: File[]
          zR1: File[]
          zR2: File[]
          bam: File
          RG_ID: string[]
          adapter: string
          adapter2: string
          bwa_output: string

outputs:

  # bams & metrics
  bams:
    type: File[]
    secondaryFiles:
      - ^.bai
    outputSource: alignment/bams
  clstats1:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: alignment/clstats1
  clstats2:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: alignment/clstats2
  md_metrics:
    type: File[]
    outputSource: alignment/md_metrics
  as_metrics:
    type: File[]
    outputSource: alignment/as_metrics
  hs_metrics:
    type: File[]
    outputSource: alignment/hs_metrics
  insert_metrics:
    type: File[]
    outputSource: alignment/insert_metrics
  insert_pdf:
    type: File[]
    outputSource: alignment/insert_pdf
  per_target_coverage:
    type: File[]
    outputSource: alignment/per_target_coverage
  qual_metrics:
    type: File[]
    outputSource: alignment/qual_metrics
  qual_pdf:
    type: File[]
    outputSource: alignment/qual_pdf
  doc_basecounts:
    type: File[]
    outputSource: alignment/doc_basecounts
  gcbias_pdf:
    type: File[]
    outputSource: alignment/gcbias_pdf
  gcbias_metrics:
    type: File[]
    outputSource: alignment/gcbias_metrics
  gcbias_summary:
    type: File[]
    outputSource: alignment/gcbias_summary
  conpair_pileups:
    type: File[]
    outputSource: alignment/conpair_pileup

  # vcf
  mutect_vcf:
    type: File
    outputSource: variant_calling/mutect_vcf
  mutect_callstats:
    type: File
    outputSource: variant_calling/mutect_callstats
  vardict_vcf:
    type: File
    outputSource: variant_calling/vardict_vcf
  combine_vcf:
    type: File
    outputSource: variant_calling/combine_vcf
    secondaryFiles:
      - .tbi
  annotate_vcf:
    type: File
    outputSource: variant_calling/annotate_vcf
  # norm vcf
  vardict_norm_vcf:
    type: File
    outputSource: variant_calling/vardict_norm_vcf
    secondaryFiles:
      - .tbi
  mutect_norm_vcf:
    type: File
    outputSource: variant_calling/mutect_norm_vcf
    secondaryFiles:
      - .tbi
  # facets
  facets_png:
    type: File[]
    outputSource: variant_calling/facets_png
  facets_txt_hisens:
    type: File
    outputSource: variant_calling/facets_txt_hisens
  facets_txt_purity:
    type: File
    outputSource: variant_calling/facets_txt_purity
  facets_out:
    type: File[]
    outputSource: variant_calling/facets_out
  facets_rdata:
    type: File[]
    outputSource: variant_calling/facets_rdata
  facets_seg:
    type: File[]
    outputSource: variant_calling/facets_seg
  facets_counts:
    type: File
    outputSource: variant_calling/facets_counts
  # structural variants
  merged_file_unfiltered:
    type: File
    outputSource: structural_variants/merged_file_unfiltered
  merged_file:
    type: File
    outputSource: structural_variants/merged_file
  maf_file:
    type: File
    outputSource: structural_variants/maf_file
  portal_file:
    type: File
    outputSource: structural_variants/portal_file
  # maf
  maf:
    type: File
    outputSource: maf_processing/maf

steps:

  alignment:
    run: ../modules/pair/alignment-pair.cwl
    in:
        runparams: runparams
        db_files: db_files
        pair: pair
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
        ref_fasta: ref_fasta
        conpair_markers_bed:
          valueFrom: ${ return inputs.db_files.conpair_markers_bed }
    out: [bams,clstats1,clstats2,md_metrics,covint_list,bed,as_metrics,hs_metrics,insert_metrics,insert_pdf,per_target_coverage,qual_metrics,qual_pdf,doc_basecounts,gcbias_pdf,gcbias_metrics,gcbias_summary,conpair_pileup]
  variant_calling:
    run: ../modules/pair/variant-calling-pair.cwl
    in:
        runparams: runparams
        db_files: db_files
        bams: alignment/bams
        pair: pair
        normal_bam:
            valueFrom: ${ return inputs.bams[1]; }
        tumor_bam:
            valueFrom: ${ return inputs.bams[0]; }
        genome:
            valueFrom: ${ return inputs.runparams.genome }
        bed: alignment/bed
        normal_sample_name:
            valueFrom: ${ return inputs.pair[1].ID; }
        tumor_sample_name:
            valueFrom: ${ return inputs.pair[0].ID; }
        dbsnp: dbsnp
        cosmic: cosmic
        mutect_dcov:
            valueFrom: ${ return inputs.runparams.mutect_dcov }
        mutect_rf:
            valueFrom: ${ return inputs.runparams.mutect_rf }
        refseq:
            valueFrom: ${ return inputs.db_files.refseq }
        hotspot_vcf:
            valueFrom: ${ return inputs.db_files.hotspot_vcf }
        ref_fasta: ref_fasta
        facets_pcval:
            valueFrom: ${ return inputs.runparams.facets_pcval }
        facets_cval:
            valueFrom: ${ return inputs.runparams.facets_cval }
        facets_snps:
            valueFrom: ${ return inputs.db_files.facets_snps }
        tmp_dir:
            valueFrom: ${ return inputs.runparams.tmp_dir; }
        complex_tn:
            valueFrom: ${ return inputs.runparams.complex_tn; }
        complex_nn:
            valueFrom: ${ return inputs.runparams.complex_nn; }
    out: [combine_vcf, annotate_vcf, facets_png, facets_txt_hisens, facets_txt_purity, facets_out, facets_rdata, facets_seg, mutect_vcf, mutect_callstats, vardict_vcf, facets_counts, vardict_norm_vcf, mutect_norm_vcf]
  structural_variants:
    run: ../modules/pair/structural-variants-pair.cwl
    in:
        runparams: runparams
        db_files: db_files
        exac_filter: exac_filter
        bams: alignment/bams
        pair: pair
        normal_bam:
            valueFrom: ${ return inputs.bams[1]; }
        tumor_bam:
            valueFrom: ${ return inputs.bams[0]; }
        genome:
            valueFrom: ${ return inputs.runparams.genome }
        normal_sample_name:
            valueFrom: ${ return inputs.pair[1].ID; }
        tumor_sample_name:
            valueFrom: ${ return inputs.pair[0].ID; }
        ref_fasta: ref_fasta
        vep_path:
            valueFrom: ${ return inputs.db_files.vep_path }
        custom_enst:
            valueFrom: ${ return inputs.db_files.custom_enst }
        vep_data:
            valueFrom: ${ return inputs.db_files.vep_data }
        delly_exclude:
            valueFrom: ${ return inputs.db_files.delly_exclude }
        delly_type:
            valueFrom: ${ return inputs.runparams.delly_type; }
        tmp_dir:
            valueFrom: ${ return inputs.runparams.tmp_dir; }
    out: [delly_sv,delly_filtered_sv,merged_file,merged_file_unfiltered,maf_file,portal_file]
  maf_processing:
    run: ../modules/pair/maf-processing-pair.cwl
    in:
        runparams: runparams
        db_files: db_files
        bams: alignment/bams
        annotate_vcf: variant_calling/annotate_vcf
        pair: pair
        genome:
            valueFrom: ${ return inputs.runparams.genome }
        ref_fasta: ref_fasta
        vep_path:
            valueFrom: ${ return inputs.db_files.vep_path }
        custom_enst:
            valueFrom: ${ return inputs.db_files.custom_enst }
        exac_filter: exac_filter
        vep_data:
            valueFrom: ${ return inputs.db_files.vep_data }
        normal_sample_name:
            valueFrom: ${ return inputs.pair[1].ID; }
        tumor_sample_name:
            valueFrom: ${ return inputs.pair[0].ID; }
        curated_bams: curated_bams
        hotspot_list:
            valueFrom: ${ return inputs.db_files.hotspot_list }
        tmp_dir:
            valueFrom: ${ return inputs.runparams.tmp_dir }
        pairing_file:
            valueFrom: ${ return inputs.db_files.pairing_file }
    out: [maf,portal_fillout]