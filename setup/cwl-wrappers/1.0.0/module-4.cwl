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

outputs:

    sid_vcf:
        type: File
        outputSource: filtering/sid_vcf
    mutect_vcf:
        type: File
        outputSource: filtering/mutect_vcf
    vardict_vcf:
        type: File
        outputSource: filtering/vardict_vcf
    pindel_vcf:
        type: File
        outputSource: filtering/pindel_vcf

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
