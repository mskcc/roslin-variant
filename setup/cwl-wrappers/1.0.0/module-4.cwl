#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#

doap:name: module-4.cwl
doap:release:
- class: doap:Version
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

    mutect_vcf:
        type: File
    mutect_callstats:
        type: File
    vardict_vcf:
        type: File
    sid_vcf:
        type: File
    sid_verbose:
        type: File
    pindel_vcf:
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

#    sid_vcf:
#        type: File
#        outputSource: normalize/sid_vcf
#    mutect_vcf:
#        type: File
#        outputSource: normalize/mutect_vcf
#    vardict_vcf:
#        type: File
#        outputSource: normalize/vardict_vcf
#    pindel_vcf:
#        type: File
#        outputSource: normalize/pindel_vcf

#    combined_vcf:
#        type: File
#        outputSource: combine/out_vcf

#    vcf2maf:
#        type: File
#        outputSource: vcf2maf/output

#    remove_variants:
#        type: File
#        outputSource: remove_variants/maf

#    fillout_tumor_normal:
#        type: File
#        outputSoruce: fillout_tumor_normal/fillout

#    replace_allele_counts:
#        type: File
#        outputSource: replace_allele_counts/maf

#    fillout_curated_bams:
#        type: File
#        outputSource: fillout_second/fillout

#    fillout_ffpe_normal:
#        type: File
#        outputSource: fillout_second/fillout

    maf:
        type: File
        outputSource: ngs_filters/output

steps:

    filtering:
        in:
            mutect_vcf: mutect_vcf
            mutect_callstats: mutect_callstats
            vardict_vcf: vardict_vcf
            sid_vcf: sid_vcf
            sid_verbose: sid_verbose
            pindel_vcf: pindel_vcf
            tumor_sample_name: tumor_sample_name
        out: [vardict_vcf, sid_vcf, pindel_vcf, mutect_vcf]
        run:
            class: Workflow
            inputs:
                mutect_vcf: File
                mutect_callstats: File
                vardict_vcf: File
                sid_vcf: File
                sid_verbose: File
                pindel_vcf: File
                tumor_sample_name: string
            outputs:
                sid_vcf:
                    type: File
                    outputSource: sid/vcf
                mutect_vcf:
                    type: File
                    outputSource: mutect/vcf
                vardict_vcf:
                    type: File
                    outputSource: vardict/vcf
                pindel_vcf:
                    type: File
                    outputSource: pindel/vcf
            steps:
                mutect:
                    run: basic-filtering.mutect/0.1.6/basic-filtering.mutect.cwl
                    in:
                        inputVcf: mutect_vcf
                        inputTxt: mutect_callstats
                        tsampleName: tumor_sample_name
                    out: [vcf]
                pindel:
                    run: basic-filtering.pindel/0.1.6/basic-filtering.pindel.cwl
                    in:
                        inputVcf: pindel_vcf
                        tsampleName: tumor_sample_name
                    out: [vcf]
                sid:
                    run: basic-filtering.somaticIndelDetector/0.1.6/basic-filtering.somaticIndelDetector.cwl
                    in:
                        inputVcf: sid_vcf
                        inputTxt: sid_verbose
                        tsampleName: tumor_sample_name
                    out: [vcf]
                vardict:
                    run: basic-filtering.vardict/0.1.6/basic-filtering.vardict.cwl
                    in:
                        inputVcf: vardict_vcf
                        tsampleName: tumor_sample_name
                    out: [vcf]

    normalize:
        in:
            mutect_vcf: filtering/mutect_vcf
            vardict_vcf: filtering/vardict_vcf
            sid_vcf: filtering/sid_vcf
            pindel_vcf: filtering/pindel_vcf
            genome: genome
        out: [vardict_vcf, sid_vcf, pindel_vcf, mutect_vcf]
        run:
            class: Workflow
            inputs:
                mutect_vcf: File
                vardict_vcf: File
                sid_vcf: File
                pindel_vcf: File
                genome: string
            outputs:
                sid_vcf:
                    type: File
                    outputSource: sid/vcf
                mutect_vcf:
                    type: File
                    outputSource: mutect/vcf
                vardict_vcf:
                    type: File
                    outputSource: vardict/vcf
                pindel_vcf:
                    type: File
                    outputSource: pindel/vcf
            steps:
                mutect:
                    run: cmo-bcftools.norm/1.3.1/cmo-bcftools.norm.cwl
                    in:
                        vcf: mutect_vcf
                        output:
                            default: "mutect-norm.vcf"
                        output_type:
                            default: "v"
                        fasta_ref: genome
                    out: [vcf]
                pindel:
                    run: cmo-bcftools.norm/1.3.1/cmo-bcftools.norm.cwl
                    in:
                        vcf: pindel_vcf
                        output:
                            default: "pindel-norm.vcf"
                        output_type:
                            default: "v"
                        fasta_ref: genome
                    out: [vcf]
                sid:
                    run: cmo-bcftools.norm/1.3.1/cmo-bcftools.norm.cwl
                    in:
                        vcf: sid_vcf
                        output:
                            default: "sid-norm.vcf"
                        output_type:
                            default: "v"
                        fasta_ref: genome
                    out: [vcf]
                vardict:
                    run: cmo-bcftools.norm/1.3.1/cmo-bcftools.norm.cwl
                    in:
                        vcf: vardict_vcf
                        output:
                            default: "vardict-norm.vcf"
                        output_type:
                            default: "v"
                        fasta_ref: genome
                    out: [vcf]

    combine:
        run: cmo-gatk.CombineVariants/3.3-0/cmo-gatk.CombineVariants.cwl
        in:
            variants_mutect: normalize/mutect_vcf
            variants_vardict: normalize/vardict_vcf
            variants_sid: normalize/sid_vcf
            variants_pindel: normalize/pindel_vcf
            unsafe:
                default: "ALLOW_SEQ_DICT_INCOMPATIBILITY"
            genotypemergeoption:
                default: "PRIORITIZE"
            rod_priority_list:
                default: ["VarDict", "MuTect", "SomaticIndelDetector", "Pindel"]
            reference_sequence: genome
            tumor_sample_name: tumor_sample_name
            out:
                valueFrom: ${ return inputs.tumor_sample_name + ".combined-variants.vcf" }
        out: [out_vcf]

    vcf2maf:
        run: cmo-vcf2maf/1.6.12/cmo-vcf2maf.cwl
        in:
            input_vcf: combine/out_vcf
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
                valueFrom: ${ return inputs.tumor_id + ".combined-variants.vep.maf" }
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
        out: [fillout]

    replace_allele_counts:
        run: replace-allele-counts/0.1.1/replace-allele-counts.cwl
        in:
            inputMaf: remove_variants/maf
            fillout: fillout_tumor_normal/fillout
            outputMaf:
                valueFrom: ${ return inputs.inputMaf.basename.replace(".maf", ".fillout.maf") }
        out: [maf]

    fillout_second:
        in:
            maf: replace_allele_counts/maf
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
                    outputSource: fillout_curated_bams/fillout
                fillout_ffpe_normal:
                    type: File
                    outputSource: fillout_ffpe_normal/fillout
            steps:
                fillout_curated_bams:
                    run: cmo-fillout/1.2.1/cmo-fillout.cwl
                    in:
                        maf: maf
                        bams: curated_bams
                        genome: genome
                        output_format:
                            default: "1"
                        output:
                            valueFrom: ${ return inputs.maf.basename.replace(".fillout.maf", ".curated.fillout"); }
                        n_threads:
                            default: 10
                    out: [fillout]
                fillout_ffpe_normal:
                    run: cmo-fillout/1.2.1/cmo-fillout.cwl
                    in:
                        maf: maf
                        bams: ffpe_normal_bams
                        genome: genome
                        output_format:
                            default: "1"
                        output:
                            valueFrom: ${ return inputs.maf.basename.replace(".fillout.maf", ".ffpe-normal.fillout"); }
                        n_threads:
                            default: 10
                    out: [fillout]

    ngs_filters:
        run: ngs-filters/1.1.4/ngs-filters.cwl
        in:
            tumor_sample_name: tumor_sample_name
            inputMaf: replace_allele_counts/maf
            outputMaf:
                valueFrom: ${ return inputs.tumor_sample_name + ".maf" }
            NormalPanelMaf: fillout_second/fillout_curated_bams
            FFPEPoolMaf: fillout_second/fillout_ffpe_normal
            inputHSP: hotspot_list
        out: [output]
