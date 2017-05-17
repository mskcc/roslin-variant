#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#

doap:name: module-3.cwl
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
    fasta: string
    bed: File
    normal_sample_id: string
    tumor_sample_id: string
    dbsnp:
        type: File
        secondaryFiles: ['^.vcf.idx']
    cosmic:
        type: File
        secondaryFiles: ['^.vcf.idx']
    rf: string[]
    sid_rf: string[]
    refseq: File

outputs:

    somaticindeldetector_vcf:
        type: File
        outputSource: call_variants/sid_vcf
    somaticindeldetector_verbose_vcf:
        type: File
        outputSource: call_variants/sid_verbose_vcf
    mutect_vcf:
        type: File
        outputSource: call_variants/mutect_vcf
    vardict_vcf:
        type: File
        outputSource: call_variants/vardict_vcf
    pindel_vcf:
        type: File
        outputSource: call_variants/pindel_vcf

steps:
    index:
        run: cmo_index/1.0.0/cmo_index.cwl
        in:
            tumor: tumor_bam
            normal: normal_bam
        out: [tumor_bam, normal_bam]
    call_variants:
        in:
            tumor_bam: index/tumor_bam
            normal_bam: index/normal_bam
            fasta: fasta
            normal_sample_id: normal_sample_id
            tumor_sample_id: tumor_sample_id
            dbsnp: dbsnp
            cosmic: cosmic
            rf: rf
            sid_rf: sid_rf
            bed: bed
            refseq: refseq
        out: [ vardict_vcf, sid_verbose_vcf, sid_vcf, pindel_vcf, mutect_vcf]
        run:
            class: Workflow
            inputs:
                tumor_bam: File
                fasta: string
                normal_bam: File
                normal_sample_id: string
                tumor_sample_id: string
                dbsnp: File
                cosmic: File
                rf: string[]
                bed: File
                sid_rf: string[]
                refseq: File #file of refseq genes...
            outputs:
                sid_verbose_vcf:
                    type: File
                    outputSource: somaticindeldetector/verbose_output
                sid_vcf:
                    type: File
                    outputSource: somaticindeldetector/output
                mutect_vcf:
                    type: File
                    outputSource: mutect/output
                vardict_vcf:
                    type: File
                    outputSource: vardict/output
                pindel_vcf:
                    type: File
                    outputSource: pindel/output
            steps:
                pindel:
                    run: cmo-pindel/0.2.5a7/cmo-pindel.cwl
                    in:
                        tumor_sample_id: tumor_sample_id
                        bams: [normal_bam, tumor_bam]
                        sample_names: [normal_sample_id, tumor_sample_id]
                        normal_sample_id: normal_sample_id
                        config_name:
                            valueFrom: $(inputs.tumor_sample_id).pindel.config
                        vcf:
                            valueFrom: $(inputs.tumor_sample_id).pindel.vcf
                        f: fasta
                        output_prefix:
                            valueFrom: $(inputs.tumor_sample_id)
                    out: [output]
                vardict:
                    run: cmo-vardict/1.4.6/cmo-vardict.cwl
                    in:
                        G: fasta
                        b: tumor_bam
                        b2: normal_bam
                        N: tumor_sample_id
                        N2: normal_sample_id
                        bedfile: bed
                        vcf:
                            valueFrom: ${ return inputs.b.basename.replace(".bam",".vardict.vcf") }

                    out: [output]
                somaticindeldetector:
                    run: cmo-gatk.SomaticIndelDetector/2.3-9/cmo-gatk.SomaticIndelDetector.cwl
                    in:
                        reference_sequence: fasta
                        tumor_bam: tumor_bam
                        normal_bam: normal_bam
                        read_filter: sid_rf
                        intervals: bed
                        refseq: refseq
                        out:
                            valueFrom: ${ return inputs.tumor_bam.basename.replace(".bam",".sid.vcf") }
                        verbose:
                            valueFrom: ${ return inputs.tumor_bam.basename.replace(".bam",".sid.verbose.vcf") }

                    out: [output, verbose_output]
                mutect:
                    run: cmo-mutect/1.1.4/cmo-mutect.cwl
                    in:
                        reference_sequence: fasta
                        dbsnp: dbsnp
                        cosmic: cosmic
                        input_file_normal: normal_bam
                        input_file_tumor: tumor_bam
                        rf: rf
                        vcf:
                            valueFrom: ${ return inputs.input_file_tumor.basename.replace(".bam",".mutect.vcf") }
                    out: [output]

