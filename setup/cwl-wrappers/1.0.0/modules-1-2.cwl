#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#

doap:name: module-1.cwl
doap:release:
- class: doap:Version
  doap:revision: '1.00'

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
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

cwlVersion: v1.0

class: Workflow
requirements:
  MultipleInputFeatureRequirement: {}
  
inputs:

    adapter: string
    adapter2: string
    fastq1: File
    fastq2: File

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

    module-1:
        run: ./module-1.cwl
        in:
            # module-1        
            adapter: adapter
            adapter2: adapter2
            fastq1: fastq1
            fastq2: fastq2
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

            # module-2
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
            rf: string[]
            fci_file: string
            num_cpu_threads_per_data_thread: string
            covariates: string[]
            abra_scratch: string
            recal_file: string
            emit_original_quals: boolean

        out: [clstats1,clstats2,bam,bai,md_metrics]

    module-2:
        run: ./module-2.cwl
        in:
            bams: bam
            fasta: genome
            hapmap: hapmap    
            dbsnp: dbsnp
            indels_1000g: indels_1000g
            snps_1000g: snps_1000g
            rf: rf
            fci_file: fci_file
            num_cpu_threads_per_data_thread: num_cpu_threads_per_data_thread
            covariates: covariates
            abra_scratch: abra_scratch
            recal_file: recal_file
            emit_original_quals: emit_original_quals

        out: [covint_list,bams]

outputs:

  covint_list:
    type:
      type: array
      items: File
    outputSource: module-2/covint_list

  bams:
    type:
      type: array
      items: File
    outputSource: modyle-2/bams
