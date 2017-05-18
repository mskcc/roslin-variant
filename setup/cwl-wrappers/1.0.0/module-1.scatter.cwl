cwlVersion: v1.0
class: Workflow
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {} 
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}
inputs:
  fastq1: string[]
  fastq2: string[]
  adapter: string[]
  adapter2: string[]
  bwa_output: string[]
  add_rg_LB: string[]
  add_rg_PL: string[]
  add_rg_ID: string[]
  add_rg_PU: string[]
  add_rg_SM: string[]
  add_rg_CN: string[]
  tmp_dir: string[]
  genome: string
outputs:
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
  bam:
    type: File
    secondaryFiles: ['^.bai']

    outputSource: mapping/bam
  bai:
    type:
      type: array
      items: File
    outputSource: mapping/bai
  md_metrics:
    type:
      type: array
      items: File
    outputSource: mapping/md_metrics
steps:
  mapping:
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
      tmp_dir: tmp_dir
    scatter: [fastq1,fastq2,adapter,adapter2,bwa_output,add_rg_LB,add_rg_PL,add_rg_ID,add_rg_PU,add_rg_SM,add_rg_CN,tmp_dir]
    scatterMethod: dotproduct
    out: [clstats1,clstats2,bam,bai,md_metrics]
    run:
      class: Workflow
      inputs: 
        fastq1: string
        fastq2: string
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
          type:
            type: array
            items: File
          outputSource: trim_galore/clstats1
        clstats2:
          type:
            type: array
            items: File
          outputSource: trim_galore/clstats2
        bam:
          type: File 
          outputSource: mark_duplicates/bam
          secondaryFiles: ['^.bai']
        bai:
          type:
            type: array
            items: File
          outputSource: mark_duplicates/bai
        md_metrics:
          type:
            type: array
            items: File
          outputSource: mark_duplicates/mdmetrics
      steps:
        trim_galore:
          run: ./cmo-trimgalore/0.2.5.mod/cmo-trimgalore.cwl
          in:
            fastq1: fastq1
            fastq2: fastq2
            adapter: adapter
            adapter2: adapter2
          out: [clfastq1,clfastq2,clstats1,clstats2]
        bwa:
          run: ./cmo-bwa-mem/0.7.5a/cmo-bwa-mem.cwl
          in: 
            fastq1: trim_galore/clfastq1
            fastq2: trim_galore/clfastq2
            output: bwa_output
            genome: genome
          out: [bam]
        add_rg_id:
          run: ./cmo-picard.AddOrReplaceReadGroups/1.96/cmo-picard.AddOrReplaceReadGroups.cwl
          in: 
            I: bwa/bam
            O: 
              valueFrom: |
                ${ return inputs.I.basename.replace(".bam", ".RG.bam") }
            LB: add_rg_LB
            PL: add_rg_PL
            ID: add_rg_ID
            PU: add_rg_PU
            SM: add_rg_SM
            CN: add_rg_CN
            SO:
              default: "coordinate"
            CREATE_INDEX:
              default: True
            TMP_DIR: tmp_dir
          out: [bam,bai]
        mark_duplicates:
          run: ./cmo-picard.MarkDuplicates/1.96/cmo-picard.MarkDuplicates.cwl
          in: 
            I: add_rg_id/bam
            O: 
              valueFrom: |
                ${ return inputs.I.basename.replace(".bam", ".md.bam") } 
            M:
              valueFrom: |
                ${ return inputs.I.basename.replace(".bam", ".md_metrics") }
            CREATE_INDEX:
              default: True
            TMP_DIR: tmp_dir
          out: [bam,bai,mdmetrics]

