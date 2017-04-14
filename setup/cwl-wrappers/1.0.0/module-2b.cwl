cwlVersion: v1.0
class: Workflow
requirements:
    MultipleInputFeatureRequirement: {}
    ScatterFeatureRequirement: {}
    SubworkflowFeatureRequirement: {}
    InlineJavascriptRequirement: {}

inputs:
    bams:
        type:
            type: array
            items: File
        secondaryFiles:
            - .bai
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
    rf: string[]
    num_cpu_threads_per_data_thread: string
    covariates: string[]
    abra_scratch: string
    recal_file: string
    emit_original_quals: boolean


############### debug

    parallel_fixmate:
        type:
            type: array
            items: File
    recal_matrix:
        type: File

outputs:
    bams:
        type:
            type: array
            items: File
        outputSource: parallel_printreads/out

steps:

    parallel_printreads:
        in:
            input_file: parallel_fixmate
            reference_sequence: fasta
            BQSR: recal_matrix
            num_cpu_threads_per_data_thread: num_cpu_threads_per_data_thread
        out: [out]
        scatter: [input_file]
        scatterMethod: dotproduct
        run:
            class: Workflow
            inputs:
                input_file:
                    type:
                        type: array
                        items: File
                reference_sequence:
                    type: string
                BQSR:
                    type: File
                num_cpu_threads_per_data_thread:
                    type: string
            outputs:
                out:
                    type:
                        type: array
                        items: File
                    outputSource: gatk_print_reads/out_bam
            steps:
                gatk_print_reads:
                    run: ./cmo-gatk.PrintReads/3.3-0/cmo-gatk.PrintReads.cwl
                    in:
                        reference_sequence: reference_sequence
                        BQSR: BQSR
                        input_file: input_file
                        num_cpu_threads_per_data_thread: num_cpu_threads_per_data_thread
                        out:
                            valueFrom: |
                                ${ return inputs.input_file.basename.replace( ".bam", ".printreads.bam");}

                    out: [out_bam]
