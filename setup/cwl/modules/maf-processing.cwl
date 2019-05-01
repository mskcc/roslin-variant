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
  doap:name: maf-processing
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
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org
  - class: foaf:Person
    foaf:name: Nikhil Kumar
    foaf:mbox: mailto:kumarn1@mskcc.org

cwlVersion: v1.0

class: Workflow
id: maf-processing
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
                pairing_file: File
                ref_fasta: string
                vep_path: string
                custom_enst: string
                vep_data: string
                hotspot_list: string
    runparams:
        type:
            type: record
            fields:
                genome: string
                tmp_dir: string
    pairs:
        type:
          type: array
          items:
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
    bams:
        type:
            type: array
            items:
                type: array
                items: File
        secondaryFiles:
            - ^.bai
    annotate_vcf: File[]
    exac_filter:
        type: File
        secondaryFiles:
            - .tbi
    curated_bams:
        type: File[]
        secondaryFiles:
            - ^.bai

outputs:

    maf:
        type: File[]
        outputSource: maf_processing_pair/maf
    portal_fillout:
        type: File[]
        outputSource: maf_processing_pair/portal_fillout

steps:
    maf_processing_pair:
        in:
            runparams: runparams
            db_files: db_files
            bams: bams
            annotate_vcf: annotate_vcf
            pair: pairs
            genome:
                valueFrom: ${ return inputs.runparams.genome }
            ref_fasta:
                valueFrom: ${ return inputs.db_files.ref_fasta }
            vep_path:
                valueFrom: ${ return inputs.db_files.vep_path }
            custom_enst:
                valueFrom: ${ return inputs.db_files.custom_enst }
            exac_filter: exac_filter
            vep_data:
                valueFrom: ${ return inputs.db_files.vep_data }
            normal_sample_name:
                valueFrom: ${ var output = []; for (var i=0; i<inputs.pair.length; i++) { output=output.concat(inputs.pair[i][1].ID); } return output; }
            tumor_sample_name:
                valueFrom: ${ var output = []; for (var i=0; i<inputs.pair.length; i++) { output=output.concat(inputs.pair[i][0].ID); } return output; }
            curated_bams: curated_bams
            hotspot_list:
                valueFrom: ${ return inputs.db_files.hotspot_list }
            tmp_dir:
                valueFrom: ${ return inputs.runparams.tmp_dir }
            pairing_file:
                valueFrom: ${ return inputs.db_files.pairing_file }
        scatter: [pair, bams, annotate_vcf, normal_sample_name, tumor_sample_name]
        scatterMethod: dotproduct
        out: [maf,portal_fillout]
        run:
            class: Workflow
            id: maf-processing-pair
            inputs:
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
                bams:
                    type: File[]
                    secondaryFiles:
                        - ^.bai
                annotate_vcf: File
                normal_sample_name: string
                tumor_sample_name: string
                genome: string
                ref_fasta: string
                vep_path: string
                custom_enst: string
                exac_filter:
                    type: File
                    secondaryFiles:
                        - .tbi
                vep_data: string
                curated_bams:
                    type: File[]
                    secondaryFiles:
                        - ^.bai
                hotspot_list: string
                tmp_dir: string
                pairing_file: File
            outputs:
                maf:
                    type: File
                    outputSource: ngs_filters/output
                portal_fillout:
                    type: File
                    outputSource: fillout_tumor_normal/portal_fillout
            steps:
                vcf2maf:
                    run: ../tools/cmo-vcf2maf/1.6.17/cmo-vcf2maf.cwl
                    in:
                        tmp_dir: tmp_dir
                        input_vcf: annotate_vcf
                        tumor_id: tumor_sample_name
                        vcf_tumor_id: tumor_sample_name
                        normal_id: normal_sample_name
                        vcf_normal_id: normal_sample_name
                        ncbi_build: genome
                        filter_vcf: exac_filter
                        vep_data: vep_data
                        ref_fasta: ref_fasta
                        vep_path: vep_path
                        custom_enst: custom_enst
                        retain_info:
                            default: "set,TYPE,FAILURE_REASON,MSI,MSILEN,SSF,LSEQ,RSEQ,STATUS,VSB"
                        retain_fmt:
                            default: "QUAL,BIAS,HIAF,PMEAN,PSTD,ALD,RD,NM,MQ,IS"
                        output_maf:
                            valueFrom: ${ return inputs.tumor_id + "." + inputs.normal_id + ".combined-variants.vep.maf" }
                    out: [output]

                remove_variants:
                    run: ../tools/remove-variants/0.1.1/remove-variants.cwl
                    in:
                        inputMaf: vcf2maf/output
                        outputMaf:
                            valueFrom: ${ return inputs.inputMaf.basename.replace(".vep.maf", ".vep.rmv.maf") }
                    out: [maf]

                fillout_tumor_normal:
                    run: ../tools/cmo-fillout/1.2.2/cmo-fillout.cwl
                    in:
                        pairing: pairing_file
                        maf: remove_variants/maf
                        bams: bams
                        genome: genome
                        output_format:
                            default: "1"
                    out: [fillout_out, portal_fillout]

                fillout_normal_panel:
                    in:
                        maf: remove_variants/portal_fillout
                        genome: genome
                        curated_bams: curated_bams
                    out: [fillout_curated_bams]
                    run:
                        class: Workflow
                        id: fillout_second
                        inputs:
                            maf: File
                            genome: string
                            curated_bams: File[]
                        outputs:
                            fillout_curated_bams:
                                type: File
                                outputSource: fillout_curated_bams_step/fillout_out
                        steps:
                            fillout_curated_bams_step:
                                run: ../tools/cmo-fillout/1.2.2/cmo-fillout.cwl
                                in:
                                    maf: maf
                                    bams: curated_bams
                                    genome: genome
                                    output_format:
                                        default: "1"
                                    output:
                                        valueFrom: ${ return inputs.maf.basename.replace(".maf", ".curated.fillout"); }
                                    n_threads:
                                        default: 10
                                out: [fillout_out]

                ngs_filters:
                    run: ../tools/ngs-filters/1.4/ngs-filters.cwl
                    in:
                        tumor_sample_name: tumor_sample_name
                        normal_sample_name: normal_sample_name
                        inputMaf: fillout_tumor_normal/portal_fillout
                        outputMaf:
                            valueFrom: ${ return inputs.tumor_sample_name + "." + inputs.normal_sample_name + ".muts.maf" }
                        NormalPanelMaf: fillout_normal_panel/fillout_curated_bams
                        inputHSP: hotspot_list
                    out: [output]
