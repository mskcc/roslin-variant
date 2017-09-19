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
  doap:name: module-4
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
            items: File
        secondaryFiles:
            - ^.bai

    combine_vcf:
        type: File

    tumor_sample_name: string
    normal_sample_name: string

    genome: string
    ref_fasta: string

    exac_filter:
        type: File
        secondaryFiles:
            - .tbi
    vep_data: string

    curated_bams:
        type:
            type: array
            items: File
        secondaryFiles:
            - ^.bai

    ffpe_normal_bams:
        type:
            type: array
            items: File
        secondaryFiles:
            - ^.bai

    hotspot_list:
        type: File

outputs:

    maf:
        type: File
        outputSource: ngs_filters/output
    portal_fillout:
        type: File
        outputSource: fillout_tumor_normal/portal_fillout

steps:

    vcf2maf:
        run: cmo-vcf2maf/1.6.12/cmo-vcf2maf.cwl
        in:
            input_vcf: combine_vcf
            tumor_id: tumor_sample_name
            vcf_tumor_id: tumor_sample_name
            normal_id: normal_sample_name
            vcf_normal_id: normal_sample_name
            ncbi_build: genome
            filter_vcf: exac_filter
            vep_data: vep_data
            ref_fasta: ref_fasta
            retain_info:
                default: "set,TYPE,FAILURE_REASON"
            output_maf:
                valueFrom: ${ return inputs.tumor_id + "." + inputs.normal_id + ".combined-variants.vep.maf" }
        out: [output]

    remove_variants:
        run: remove-variants/0.1.1/remove-variants.cwl
        in:
            inputMaf: vcf2maf/output
            outputMaf:
                valueFrom: ${ return inputs.inputMaf.basename.replace(".vep.maf", ".vep.rmv.maf") }
        out: [maf]

    fillout_tumor_normal:
        run: cmo-fillout/1.2.1/cmo-fillout.cwl
        in:
            maf: remove_variants/maf
            bams: bams
            genome: genome
            output_format:
                default: "1"
        out: [fillout, portal_fillout]

#    replace_allele_counts:
#        run: replace-allele-counts/0.2.0/replace-allele-counts.cwl
#        in:
#            inputMaf: remove_variants/maf
#            fillout: fillout_tumor_normal/fillout
#            outputMaf:
#                valueFrom: ${ return inputs.inputMaf.basename.replace(".maf", ".fillout.maf") }
#        out: [maf]

    fillout_second:
        in:
            maf: fillout_tumor_normal/portal_fillout
            genome: genome
            curated_bams: curated_bams
            ffpe_normal_bams: ffpe_normal_bams
        out: [fillout_curated_bams, fillout_ffpe_normal]
        run:
            class: Workflow
            inputs:
                maf: File
                genome: string
                curated_bams:
                    type:
                        type: array
                        items: File
                ffpe_normal_bams:
                    type:
                        type: array
                        items: File
            outputs:
                fillout_curated_bams:
                    type: File
                    outputSource: fillout_curated_bams_step/fillout
                fillout_ffpe_normal:
                    type: File
                    outputSource: fillout_ffpe_normal_step/fillout
            steps:
                fillout_curated_bams_step:
                    run: cmo-fillout/1.2.1/cmo-fillout.cwl
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
                    out: [fillout]
                fillout_ffpe_normal_step:
                    run: cmo-fillout/1.2.1/cmo-fillout.cwl
                    in:
                        maf: maf
                        bams: ffpe_normal_bams
                        genome: genome
                        output_format:
                            default: "1"
                        output:
                            valueFrom: ${ return inputs.maf.basename.replace(".maf", ".ffpe-normal.fillout"); }
                        n_threads:
                            default: 10
                    out: [fillout]

    ngs_filters:
        run: ngs-filters/1.1.4/ngs-filters.cwl
        in:
            tumor_sample_name: tumor_sample_name
            normal_sample_name: normal_sample_name
            inputMaf: fillout_tumor_normal/portal_fillout
            outputMaf:
                valueFrom: ${ return inputs.tumor_sample_name + "." + inputs.normal_sample_name + ".maf" }
            NormalPanelMaf: fillout_second/fillout_curated_bams
            FFPEPoolMaf: fillout_second/fillout_ffpe_normal
            inputHSP: hotspot_list
        out: [output]
