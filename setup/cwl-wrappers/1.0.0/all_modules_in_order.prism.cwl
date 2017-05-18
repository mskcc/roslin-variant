cwlVersion: v1.0
class: Workflow
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
inputs:
  fastq1:
    type: 
      type: array
      items:
        type: array
        items: File
  fastq2:
    type: 
      type: array
      items:
        type: array
        items: File
  adapter:
    type: 
      type: array
      items:
        type: array
        items: string
  adapter2:
    type: 
      type: array
      items:
        type: array
        items: string
  bwa_output:
    type: 
      type: array
      items:
        type: array
        items: string
  add_rg_LB:
    type: 
      type: array
      items:
        type: array
        items: string
  add_rg_PL:
    type: 
      type: array
      items:
        type: array
        items: string
  add_rg_ID:
    type: 
      type: array
      items:
        type: array
        items: string
  add_rg_PU:
    type: 
      type: array
      items:
        type: array
        items: string
  add_rg_SM:
    type: 
      type: array
      items:
        type: array
        items: string
  add_rg_CN:
    type: 
      type: array
      items:
        type: array
        items: string
  add_rg_output:
    type: 
      type: array
      items:
        type: array
        items: string
  md_output:
    type: 
      type: array
      items:
        type: array
        items: string
  md_metrics_output:
    type: 
      type: array
      items:
        type: array
        items: string
  tmp_dir:
    type: 
      type: array
      items:
        type: array
        items: string
  fasta: string
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
  genome: string
  rf: string[]
  covariates: string[]
  abra_scratch: string
  intervals: string
  sid_rf:
    type:
      type: array
      items: string
  refseq: File
  pairs:
    type:
      type: array
      items:
        type: array
        items: string


outputs:
  bams: 
    type: 
      type: array
      items: File
    outputSource: realignment/bams
  clstats1: 
    type: 
      type: array
      items: File
    outputSource: mapping/clstats1
  clstats2: 
    type: 
      type: array
      items: File
    outputSource: mapping/clstats2
  md_metrics: 
    type: 
      type: array
      items: File
    outputSource: mapping/md_metrics
  mutect_vcf:
    type:
      type: array
      items: File
    outputSource: variant_calling/mutect_vcf
steps:
  mapping:
    run:  module-1.scatter.cwl
    in:
      fastq1: fastq1
      fastq2: fastq2
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
      add_rg_output: add_rg_output
      tmp_dir: tmp_dir
    out: [clstats1, clstats2, bam, bai, md_metrics]
    scatter: [fastq1,fastq2,adapter,adapter2,bwa_output,add_rg_LB,add_rg_PL,add_rg_ID,add_rg_PU,add_rg_SM,add_rg_CN,tmp_dir]
    scatterMethod: dotproduct
  flatten_samples:
    #hack to remove array of arrays
    run: flatten_array/1.0.0/flatten_array.cwl
    in:
      bams: mapping/bam
    out: [bams]
  realignment:
    run: module-2.cwl
    in:
      bams: flatten_samples/bams
      hapmap: hapmap
      dbsnp: dbsnp
      indels_1000g: indels_1000g
      snps_1000g: snps_1000g
      covariates: covariates
      abra_scratch: abra_scratch
      fasta: fasta
      intervals: intervals
    out: [bams, covint_list, covint_bed]
  pairing:
    run: sort_bams_by_pair/1.0.0/sort_bams_by_pair.cwl
    in:
      bams: realignment/bams
      pairs: pairs
    out: [tumor_bams, normal_bams, tumor_sample_ids, normal_sample_ids]
  variant_calling:
    run: module-3.cwl
    in: 
      tumor_bam: pairing/tumor_bams
      normal_bam: pairing/normal_bams
      fasta: fasta
      bed: realignment/covint_bed 
      normal_sample_id: pairing/normal_sample_ids
      tumor_sample_id: pairing/tumor_sample_ids
      dbsnp: dbsnp
      cosmic: cosmic
      rf: rf
      sid_rf: sid_rf
      refseq: refseq 
    out: [somaticindeldetector_vcf, somaticindeldetector_verbose_vcf, mutect_vcf, vardict_vcf, pindel_vcf]
    scatter: [tumor_bam, normal_bam, normal_sample_id, tumor_sample_id]
    scatterMethod: dotproduct







  







 
