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
  doap:name: module-3
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

    tumor_bam:
        type: File
    normal_bam:
        type: File
    genome: string
    bed: File
    normal_sample_name: string
    tumor_sample_name: string
    dbsnp:
        type: File
        secondaryFiles: ['^.vcf.idx']
    cosmic:
        type: File
        secondaryFiles: ['^.vcf.idx']
    mutect_dcov: int
    mutect_rf: string[]
    refseq: File

outputs:

    combine_vcf:
        type: File
        outputSource: combine/out_vcf
    facets_png:
        type: File
        outputSource: call_variants/facets_png
    facets_txt:
        type: File
        outputSource: call_variants/facets_txt
    facets_out:
        type: File
        outputSource: call_variants/facets_out
    facets_rdata:
        type: File
        outputSource: call_variants/facets_rdata
    facets_seg:
        type: File
        outputSource: call_variants/facets_seg
    mutect_vcf:
        type: File
        outputSource: call_variants/mutect_vcf
    mutect_callstats:
        type: File
        outputSource: call_variants/mutect_callstats
    vardict_vcf:
        type: File
        outputSource: call_variants/vardict_vcf
    pindel_vcf:
        type: File
        outputSource: call_variants/pindel_vcf


steps:

    index:
        run: cmo-index/1.0.0/cmo-index.cwl
        in:
            tumor: tumor_bam
            normal: normal_bam
        out: [tumor_bam, normal_bam]
    call_variants:
        in:
            tumor_bam: index/tumor_bam
            normal_bam: index/normal_bam
            genome: genome
            normal_sample_name: normal_sample_name
            tumor_sample_name: tumor_sample_name
            dbsnp: dbsnp
            cosmic: cosmic
            mutect_dcov: mutect_dcov
            mutect_rf: mutect_rf
            bed: bed
            refseq: refseq
        out: [ vardict_vcf, pindel_vcf, mutect_vcf, mutect_callstats, facets_png, facets_txt, facets_out, facets_rdata, facets_seg]
        run:
            class: Workflow
            inputs:
                tumor_bam: File
                genome: string
                normal_bam: File
                normal_sample_name: string
                tumor_sample_name: string
                dbsnp: File
                cosmic: File
                mutect_dcov: int
                mutect_rf: string[]
                bed: File
                refseq: File #file of refseq genes...
            outputs:
                mutect_vcf:
                    type: File
                    outputSource: mutect/output
                mutect_callstats:
                    type: File
                    outputSource: mutect/callstats_output
                vardict_vcf:
                    type: File
                    outputSource: vardict/output
                pindel_vcf:
                    type: File
                    outputSource: pindel/output
                facets_png:
                    type: File
                    outputSource: facets/facets_png_output
                facets_txt:
                    type: File
                    outputSource: facets/facets_txt_output
                facets_out:
                    type: File
                    outputSource: facets/facets_out_output
                facets_rdata:
                    type: File
                    outputSource: facets/facets_rdata_output
                facets_seg:
                    type: File
                    outputSource: facets/facets_seg_output
            steps:
                facets:
                    run: facets.cwl
                    in:
                        normal_bam: normal_bam
                        tumor_bam: tumor_bam
                        genome: genome
                    out: [facets_png_output, facets_txt_output, facets_out_output, facets_rdata_output, facets_seg_output]
                pindel:
                    run: cmo-pindel/0.2.5b8/cmo-pindel.cwl
                    in:
                        bams: [normal_bam, tumor_bam]
                        sample_names: [normal_sample_name, tumor_sample_name]
                        vcf:
                            valueFrom: ${ return inputs.bams[1].basename.replace(".bam", ".") + inputs.bams[0].basename.replace(".bam", ".pindel.vcf") }
                        fasta: genome
                        output_prefix: tumor_sample_name
                    out: [output]
                vardict:
                    run: cmo-vardict/1.4.6/cmo-vardict.cwl
                    in:
                        G: genome
                        b: tumor_bam
                        b2: normal_bam
                        N: tumor_sample_name
                        N2: normal_sample_name
                        bedfile: bed
                        vcf:
                            valueFrom: ${ return inputs.b.basename.replace(".bam", ".") + inputs.b2.basename.replace(".bam", ".vardict.vcf") }
                    out: [output]
                mutect:
                    run: cmo-mutect/1.1.4/cmo-mutect.cwl
                    in:
                        reference_sequence: genome
                        dbsnp: dbsnp
                        cosmic: cosmic
                        input_file_normal: normal_bam
                        input_file_tumor: tumor_bam
                        read_filter: mutect_rf
                        downsample_to_coverage: mutect_dcov
                        vcf:
                            valueFrom: ${ return inputs.input_file_tumor.basename.replace(".bam",".") + inputs.input_file_normal.basename.replace(".bam", ".mutect.vcf") }
                        out:
                            valueFrom: ${ return inputs.input_file_tumor.basename.replace(".bam",".") + inputs.input_file_normal.basename.replace(".bam", ".mutect.txt") }
                    out: [output, callstats_output]
    filtering:
        in:
            mutect_vcf: call_variants/mutect_vcf
            mutect_callstats: call_variants/mutect_callstats
            vardict_vcf: call_variants/vardict_vcf
            pindel_vcf: call_variants/pindel_vcf
            tumor_sample_name: tumor_sample_name
        out: [vardict_vcf_filtering_output, pindel_vcf_filtering_output, mutect_vcf_filtering_output]
        run:
            class: Workflow
            inputs:
                mutect_vcf: File
                mutect_callstats: File
                vardict_vcf: File
                pindel_vcf: File
                tumor_sample_name: string
            outputs:                
                mutect_vcf_filtering_output:
                    type: File
                    outputSource: mutect_filtering_step/vcf
                vardict_vcf_filtering_output:
                    type: File
                    outputSource: vardict_filtering_step/vcf
                pindel_vcf_filtering_output:
                    type: File
                    outputSource: pindel_filtering_step/vcf
            steps:
                mutect_filtering_step:
                    run: basic-filtering.mutect/0.1.7/basic-filtering.mutect.cwl
                    in:
                        inputVcf: mutect_vcf
                        inputTxt: mutect_callstats
                        tsampleName: tumor_sample_name
                    out: [vcf]
                pindel_filtering_step:
                    run: basic-filtering.pindel/0.1.7/basic-filtering.pindel.cwl
                    in:
                        inputVcf: pindel_vcf
                        tsampleName: tumor_sample_name
                    out: [vcf]
                vardict_filtering_step:
                    run: basic-filtering.vardict/0.1.7/basic-filtering.vardict.cwl
                    in:
                        inputVcf: vardict_vcf
                        tsampleName: tumor_sample_name
                    out: [vcf]
    normalize:
        in:
            mutect_vcf: filtering/mutect_vcf_filtering_output
            vardict_vcf: filtering/vardict_vcf_filtering_output
            pindel_vcf: filtering/pindel_vcf_filtering_output
            genome: genome
        out: [vardict_vcf_norm_output, pindel_vcf_norm_output, mutect_vcf_norm_output]
        run:
            class: Workflow
            inputs:
                mutect_vcf: File
                vardict_vcf: File
                pindel_vcf: File
                genome: string
            outputs:
                mutect_vcf_norm_output:
                    type: File
                    outputSource: mutect_norm_step/vcf_output_file
                vardict_vcf_norm_output:
                    type: File
                    outputSource: vardict_norm_step/vcf_output_file
                pindel_vcf_norm_output:
                    type: File
                    outputSource: pindel_norm_step/vcf_output_file
            steps:
                mutect_norm_step:
                    run: cmo-bcftools.norm/1.3.1/cmo-bcftools.norm.cwl
                    in:
                        vcf: mutect_vcf
                        output:
                            default: "mutect-norm.vcf"
                        output_type:
                            default: "v"
                        fasta_ref: genome
                    out: [vcf_output_file]
                pindel_norm_step:
                    run: cmo-bcftools.norm/1.3.1/cmo-bcftools.norm.cwl
                    in:
                        vcf: pindel_vcf
                        output:
                            default: "pindel-norm.vcf"
                        output_type:
                            default: "v"
                        fasta_ref: genome
                    out: [vcf_output_file]
                vardict_norm_step:
                    run: cmo-bcftools.norm/1.3.1/cmo-bcftools.norm.cwl
                    in:
                        vcf: vardict_vcf
                        output:
                            default: "vardict-norm.vcf"
                        output_type:
                            default: "v"
                        fasta_ref: genome
                    out: [vcf_output_file]

    combine:
        run: cmo-gatk.CombineVariants/3.3-0/cmo-gatk.CombineVariants.cwl
        in:
            variants_mutect: normalize/mutect_vcf_norm_output
            variants_vardict: normalize/vardict_vcf_norm_output
            variants_pindel: normalize/pindel_vcf_norm_output
            unsafe:
                default: "ALLOW_SEQ_DICT_INCOMPATIBILITY"
            genotypemergeoption:
                default: "PRIORITIZE"
            rod_priority_list:
                default: ["VarDict", "MuTect", "Pindel"]
            reference_sequence: genome
            tumor_sample_name: tumor_sample_name
            normal_sample_name: normal_sample_name
            out:
                valueFrom: ${ return inputs.tumor_sample_name +"."+inputs.normal_sample_name+".combined-variants.vcf" }
        out: [out_vcf]

