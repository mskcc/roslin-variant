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
  doap:name: realignment
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
id: realignment
requirements:
    MultipleInputFeatureRequirement: {}
    ScatterFeatureRequirement: {}
    SubworkflowFeatureRequirement: {}
    InlineJavascriptRequirement: {}

inputs:
    bams:
        type: File[]
        secondaryFiles:
            - ^.bai
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
                R1: string[]
                R2: string[]
                RG_ID: string[]
                adapter: string
                adapter2: string
                bwa_output: string
    genome: string
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
    covariates: string[]
    abra_scratch: string
    abra_ram_min: int
    tmp_dir: string
outputs:
    covint_list:
        type: File
        outputSource: gatk_find_covered_intervals/fci_list
    covint_bed:
        type: File
        outputSource: list2bed/output_file
    outbams:
        type: File[]
        secondaryFiles:
            - ^.bai
        outputSource: parallel_printreads/out
steps:
    gatk_find_covered_intervals:
        run: ../../tools/cmo-gatk.FindCoveredIntervals/3.3-0/cmo-gatk.FindCoveredIntervals.cwl
        in:
            java_temp: tmp_dir
            pair: pair
            reference_sequence: genome
            coverage_threshold:
              valueFrom: ${ return ["3"];}
            minBaseQuality:
              valueFrom: ${ return ["20"];}
            intervals:
              valueFrom: ${ return ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y","MT"];}
            input_file: bams
            out:
                valueFrom: ${ return inputs.pair[0].ID + "." + inputs.pair[1].ID +  ".fci.list"; }
        out: [fci_list]

    list2bed:
        run: ../../tools/cmo-list2bed/1.0.1/cmo-list2bed.cwl
        in:
            input_file: gatk_find_covered_intervals/fci_list
            output_filename:
                valueFrom: ${ return inputs.input_file.basename.replace(".list", ".bed"); }
        out: [output_file]
    abra:
        run: ../../tools/cmo-abra/2.17/cmo-abra.cwl
        in:
            abra_ram_min: abra_ram_min
            in: bams
            ref: genome
            out:
                valueFrom: ${ return inputs.in.map(function(x){ return x.basename.replace(".bam", ".abra.bam"); }); }
            working: abra_scratch
            targets: list2bed/output_file
        out: [outbams]

    gatk_base_recalibrator:
        run: ../../tools/cmo-gatk.BaseRecalibrator/3.3-0/cmo-gatk.BaseRecalibrator.cwl
        in:
            java_temp: tmp_dir
            reference_sequence: genome
            input_file: abra/outbams
            dbsnp: dbsnp
            hapmap: hapmap
            indels_1000g: indels_1000g
            snps_1000g: snps_1000g
            knownSites:
                valueFrom: ${return [inputs.dbsnp,inputs.hapmap, inputs.indels_1000g, inputs.snps_1000g]}
            covariate: covariates
            out:
                valueFrom: ${ return "recal.matrix"; }
            read_filter:
              valueFrom: ${ return ["BadCigar"]; }
        out: [recal_matrix]

    parallel_printreads:
        in:
            input_file: abra/outbams
            reference_sequence: genome
            BQSR: gatk_base_recalibrator/recal_matrix
            tmp_dir: tmp_dir
        out: [out]
        scatter: [input_file]
        scatterMethod: dotproduct
        run:
            class: Workflow
            id: parallel_printreads
            inputs:
                input_file: File
                reference_sequence: string
                BQSR: File
                tmp_dir: string
            outputs:
                out:
                    type: File
                    secondaryFiles:
                        - ^.bai
                    outputSource: gatk_print_reads/out_bam
            steps:
                gatk_print_reads:
                    run: ../../tools/cmo-gatk.PrintReads/3.3-0/cmo-gatk.PrintReads.cwl
                    in:
                        reference_sequence: reference_sequence
                        BQSR: BQSR
                        input_file: input_file
                        java_temp: tmp_dir
                        num_cpu_threads_per_data_thread:
                            valueFrom: ${ return "5"; }
                        emit_original_quals:
                            valueFrom: ${ return true; }
                        baq:
                            valueFrom: ${ return ['RECALCULATE'];}
                        out:
                            valueFrom: ${ return inputs.input_file.basename.replace(".bam", ".printreads.bam");}
                    out: [out_bam]
