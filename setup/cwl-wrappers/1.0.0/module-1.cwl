cwlVersion: v1.0

class: Workflow
requirements:
  MultipleInputFeatureRequirement: {}
  
inputs:

    out_dir: string
    adapter: string
    adapter2: string
    fastq1: string
    fastq2: string
    paired: boolean

    genome: string
    bwa_output: string

    add_rg_LB: string
    add_rg_PL: string
    add_rg_ID: string
    add_rg_PU: string
    add_rg_SM: string
    add_rg_CN: string
    add_rg_output: string

    md_output: string
    md_metrics_output: string

    create_index: boolean

    tmp_dir: string

steps:

    cmo-trimgalore:
        run: ./cmo-trimgalore/0.2.5.mod/cmo-trimgalore.cwl
        in:
            out_dir: out_dir
            adapter: adapter
            adapter2: adapter2
            fastq1: fastq1
            fastq2: fastq2
            paired: paired
            quality:
              default: "1"
        out: [clfastq1,clfastq2,clstats1,clstats2]

    cmo-bwa-mem:
        run: ./cmo-bwa-mem/0.7.5a/cmo-bwa-mem.cwl
        in:
            fastq1: cmo-trimgalore/clfastq1
            fastq2: cmo-trimgalore/clfastq2
            genome: genome
            output: bwa_output
        out: [bam]

    cmo-picard.AddOrReplaceReadGroups:
        run: ./cmo-picard.AddOrReplaceReadGroups/1.96/cmo-picard.AddOrReplaceReadGroups.cwl
        in: 
            I: cmo-bwa-mem/bam
            O: add_rg_output
            LB: add_rg_LB
            PL: add_rg_PL
            ID: add_rg_ID
            PU: add_rg_PU
            SM: add_rg_SM
            CN: add_rg_CN
            SO:
              default: "coordinate"
            CREATE_INDEX: create_index
            TMP_DIR: tmp_dir
        out: [bam, bai]

    cmo-picard.MarkDuplicates:
        run: ./cmo-picard.MarkDuplicates/1.96/cmo-picard.MarkDuplicates.cwl
        in: 
            I: cmo-picard.AddOrReplaceReadGroups/bam
            O: md_output
            M: md_metrics_output
            CREATE_INDEX: create_index
            TMP_DIR: tmp_dir
        out: [bam,bai,mdmetrics]        

outputs:

  clstats1:
    type: File
    outputSource: cmo-trimgalore/clstats1

  clstats2: 
    type: File
    outputSource: cmo-trimgalore/clstats2

  bam:
    type: File
    outputSource: cmo-picard.MarkDuplicates/bam

  bai:
    type: File
    outputSource: cmo-picard.MarkDuplicates/bai

  md_metrics:
    type: File
    outputSource: cmo-picard.MarkDuplicates/mdmetrics
