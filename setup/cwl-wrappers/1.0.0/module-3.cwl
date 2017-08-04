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
    normal_sample_id: string
    tumor_sample_id: string
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
            normal_sample_id: normal_sample_id
            tumor_sample_id: tumor_sample_id
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
                normal_sample_id: string
                tumor_sample_id: string
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
                        sample_names: [normal_sample_id, tumor_sample_id]
                        vcf:
                            valueFrom: ${ return inputs.bams[1].basename.replace(".bam", ".pindel.vcf") }
                        fasta: genome
                        output_prefix: tumor_sample_id
                    out: [output]
                vardict:
                    run: cmo-vardict/1.4.6/cmo-vardict.cwl
                    in:
                        G: genome
                        b: tumor_bam
                        b2: normal_bam
                        N: tumor_sample_id
                        N2: normal_sample_id
                        bedfile: bed
                        vcf:
                            valueFrom: ${ return inputs.b.basename.replace(".bam", ".vardict.vcf") }
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
                            valueFrom: ${ return inputs.input_file_tumor.basename.replace(".bam", ".mutect.vcf") }
                        out:
                            valueFrom: ${ return inputs.input_file_tumor.basename.replace(".bam", ".mutect.txt") }
                    out: [output, callstats_output]
