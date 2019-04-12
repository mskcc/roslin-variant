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
  - class: foaf:Person
    foaf:name: Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org

cwlVersion: v1.0

class: Workflow
label: module-3
requirements:
    MultipleInputFeatureRequirement: {}
    ScatterFeatureRequirement: {}
    SubworkflowFeatureRequirement: {}
    InlineJavascriptRequirement: {}
    StepInputExpressionRequirement: {}

inputs:

    runparams:
        type:
            type: record
            fields:
                tmp_dir: string
                complex_tn: int
                complex_nn: int
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
        secondaryFiles:
            - .idx
    cosmic:
        type: File
        secondaryFiles:
            - .idx
    mutect_dcov: int
    mutect_rf: string[]
    refseq: File
    hotspot_vcf: string
    ref_fasta: string
    facets_pcval: int
    facets_cval: int
    facets_snps: string

outputs:

    combine_vcf:
        type: File
        outputSource: tabix_index/tabix_output_file
        secondaryFiles:
        - .tbi
    annotate_vcf:
        type: File
        outputSource: annotate/annotate_vcf_output_file
    facets_png:
        type: File[]
        outputSource: call_variants/facets_png
    facets_txt_hisens:
        type: File
        outputSource: call_variants/facets_txt_hisens
    facets_txt_purity:
        type: File
        outputSource: call_variants/facets_txt_purity
    facets_out:
        type: File[]
        outputSource: call_variants/facets_out
    facets_rdata:
        type: File[]
        outputSource: call_variants/facets_rdata
    facets_seg:
        type: File[]
        outputSource: call_variants/facets_seg
    facets_counts:
        type: File
        outputSource: call_variants/facets_counts
    mutect_vcf:
        type: File
        outputSource: call_variants/mutect_vcf
    mutect_callstats:
        type: File
        outputSource: call_variants/mutect_callstats
    vardict_vcf:
        type: File
        outputSource: call_variants/vardict_vcf
    vardict_norm_vcf:
        type: File
        outputSource: filtering/vardict_vcf_filtering_output
        secondaryFiles:
            - .tbi
    mutect_norm_vcf:
        type: File
        outputSource: filtering/mutect_vcf_filtering_output
        secondaryFiles:
            - .tbi

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
            facets_pcval: facets_pcval
            facets_cval: facets_cval
        out: [ vardict_vcf, mutect_vcf, mutect_callstats, facets_png, facets_txt_hisens, facets_txt_purity, facets_out, facets_rdata, facets_seg, facets_counts]
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
                facets_pcval: int
                facets_cval: int
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
                facets_png:
                    type: File[]
                    outputSource: facets/facets_png_output
                facets_txt_hisens:
                    type: File
                    outputSource: facets/facets_txt_output_hisens
                facets_txt_purity:
                    type: File
                    outputSource: facets/facets_txt_output_purity
                facets_out:
                    type: File[]
                    outputSource: facets/facets_out_output
                facets_rdata:
                    type: File[]
                    outputSource: facets/facets_rdata_output
                facets_seg:
                    type: File[]
                    outputSource: facets/facets_seg_output
                facets_counts:
                    type: File
                    outputSource: facets/facets_counts_output
            steps:
                facets:
                    run: facets.cwl
                    in:
                        normal_bam: normal_bam
                        tumor_bam: tumor_bam
                        tumor_sample_name: tumor_sample_name 
                        genome: genome
                        facets_pcval: facets_pcval
                        facets_cval: facets_cval
                    out: [facets_png_output, facets_txt_output_hisens, facets_txt_output_purity, facets_out_output, facets_rdata_output, facets_seg_output, facets_counts_output]
                vardict:
                    run: cmo-vardict/1.5.1/cmo-vardict.cwl
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
                        intervals: bed
                        vcf:
                            valueFrom: ${ return inputs.input_file_tumor.basename.replace(".bam",".") + inputs.input_file_normal.basename.replace(".bam", ".mutect.vcf") }
                        out:
                            valueFrom: ${ return inputs.input_file_tumor.basename.replace(".bam",".") + inputs.input_file_normal.basename.replace(".bam", ".mutect.txt") }
                    out: [output, callstats_output]
    filtering:
        in:
            runparams: runparams
            complex_nn:
              valueFrom: ${ return inputs.runparams.complex_nn; }
            complex_tn:
              valueFrom: ${ return inputs.runparams.complex_tn; }
            normal_bam: normal_bam
            tumor_bam: tumor_bam
            mutect_vcf: call_variants/mutect_vcf
            mutect_callstats: call_variants/mutect_callstats
            vardict_vcf: call_variants/vardict_vcf
            tumor_sample_name: tumor_sample_name
            hotspot_vcf: hotspot_vcf
            ref_fasta: ref_fasta
        out: [vardict_vcf_filtering_output, mutect_vcf_filtering_output]
        run:
            class: Workflow
            inputs:
                complex_nn: float
                complex_tn: float
                normal_bam: File
                tumor_bam: File
                mutect_vcf: File
                mutect_callstats: File
                vardict_vcf: File
                hotspot_vcf: File
                tumor_sample_name: string
                ref_fasta: string
            outputs:
                mutect_vcf_filtering_output:
                    type: File
                    outputSource: mutect_filtering_step/vcf
                    secondaryFiles:
                        - .tbi
                vardict_vcf_filtering_output:
                    type: File
                    outputSource: vardict_filtering_step/vcf
                    secondaryFiles:
                        - .tbi
            steps:
                mutect_filtering_step:
                    run: basic-filtering.mutect/0.3/basic-filtering.mutect.cwl
                    in:
                        inputVcf: mutect_vcf
                        inputTxt: mutect_callstats
                        tsampleName: tumor_sample_name
                        hotspotVcf: hotspot_vcf
                        refFasta: ref_fasta
                    out: [vcf]
                vardict_complex_filtering_step:
                    run: basic-filtering.complex/0.3/basic-filtering.complex.cwl
                    in:
                        nrm_noise: complex_nn
                        tum_noise: complex_tn
                        inputVcf: vardict_vcf
                        normal_bam: normal_bam
                        tumor_bam: tumor_bam
                        tumor_id: tumor_sample_name
                        refFasta: ref_fasta
                        output_vcf:
                            valueFrom: ${ return inputs.inputVcf.basename.replace(".vcf", ".complex_filtered.vcf"); }
                    out: [vcf]
                vardict_filtering_step:
                    run: basic-filtering.vardict/0.3/basic-filtering.vardict.cwl
                    in:
                        inputVcf: vardict_complex_filtering_step/vcf
                        tsampleName: tumor_sample_name
                        hotspotVcf: hotspot_vcf
                        refFasta: ref_fasta
                    out: [vcf]

    create_vcf_file_array:
        in:
            vcf_vardict: filtering/vardict_vcf_filtering_output
            vcf_mutect: filtering/mutect_vcf_filtering_output
        out: [ vcf_files ]
        run:
            class: ExpressionTool
            id: create-vcf-file-array
            requirements:
                - class: InlineJavascriptRequirement
            inputs:
                vcf_vardict:
                    type: File
                    secondaryFiles:
                        - .tbi
                vcf_mutect:
                    type: File
                    secondaryFiles:
                        - .tbi
            outputs:
                vcf_files:
                    type:
                        type: array
                        items: File
                    secondaryFiles:
                        - .tbi
            expression: "${ var project_object = {};
                project_object['vcf_files'] = [ inputs.vcf_vardict, inputs.vcf_mutect];
                return project_object;
            }"

    concat:
        run: bcftools.concat/1.9/bcftools.concat.cwl
        in:
            vcf_files_tbi: create_vcf_file_array/vcf_files
            tumor_sample_name: tumor_sample_name
            normal_sample_name: normal_sample_name
            allow_overlaps:
                valueFrom: ${ return true; }
            rm_dups:
                valueFrom: ${ return "all"; }
            output_type:
                valueFrom: ${ return "z"; }
            output:
                valueFrom: ${ return inputs.tumor_sample_name + "." + inputs.normal_sample_name + ".combined-variants.vcf.gz" }
        out: [concat_vcf_output_file]
    tabix_index:
        run: tabix/1.9/tabix.cwl
        in:
            input_vcf: concat/concat_vcf_output_file
            preset:
                valueFrom: ${ return "vcf"; }
        out: [tabix_output_file]
    annotate:
        run: bcftools.annotate/1.9/bcftools.annotate.cwl
        in:
            annotations: filtering/mutect_vcf_filtering_output
            tumor_sample_name: tumor_sample_name
            normal_sample_name: normal_sample_name
            columns:
                valueFrom: ${ return ["INFO/FAILURE_REASON"]; }
            mark_sites:
                valueFrom: ${ return "+set=MuTect"; }
            vcf_file_tbi: tabix_index/tabix_output_file
            output:
                valueFrom: ${ return inputs.tumor_sample_name + "." + inputs.normal_sample_name + ".annotate-variants.vcf" }
        out: [annotate_vcf_output_file]
