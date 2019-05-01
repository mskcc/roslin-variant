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
  doap:name: variant-calling
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
id: variant-calling
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
                refseq: File
                ref_fasta: string
                hotspot_vcf: string
                facets_snps: string
    runparams:
        type:
            type: record
            fields:
                tmp_dir: string
                genome: string
                mutect_dcov: int
                mutect_rf: string[]
                complex_tn: float
                complex_nn: float
                facets_pcval: int
                facets_cval: int
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
    beds: File[]
    dbsnp:
        type: File
        secondaryFiles:
            - .idx
    cosmic:
        type: File
        secondaryFiles:
            - .idx

outputs:

    combine_vcf:
        type: File[]
        outputSource: variants_pair/combine_vcf
        secondaryFiles:
            - .tbi
    annotate_vcf:
        type: File[]
        outputSource: variants_pair/annotate_vcf
    facets_png:
        type:
            type: array
            items:
                type: array
                items: File
        outputSource: variants_pair/facets_png
    facets_txt_hisens:
        type: File[]
        outputSource: variants_pair/facets_txt_hisens
    facets_txt_purity:
        type: File[]
        outputSource: variants_pair/facets_txt_purity
    facets_out:
        type:
            type: array
            items:
                type: array
                items: File
        outputSource: variants_pair/facets_out
    facets_rdata:
        type:
            type: array
            items:
                type: array
                items: File
        outputSource: variants_pair/facets_rdata
    facets_seg:
        type:
            type: array
            items:
                type: array
                items: File
        outputSource: variants_pair/facets_seg
    facets_counts:
        type: File[]
        outputSource: variants_pair/facets_counts
    mutect_vcf:
        type: File[]
        outputSource: variants_pair/mutect_vcf
    mutect_callstats:
        type: File[]
        outputSource: variants_pair/mutect_callstats
    vardict_vcf:
        type: File[]
        outputSource: variants_pair/vardict_vcf
    vardict_norm_vcf:
        type: File[]
        outputSource: variants_pair/vardict_norm_vcf
        secondaryFiles:
            - .tbi
    mutect_norm_vcf:
        type: File[]
        outputSource: variants_pair/mutect_norm_vcf
        secondaryFiles:
            - .tbi

steps:
    variants_pair:
        run: ../pair/variant-calling-pair.cwl
        in:
            runparams: runparams
            db_files: db_files
            bams: bams
            pair: pairs
            normal_bam:
                valueFrom: ${ var output = []; for (var i=0; i<inputs.bams.length; i++) { output=output.concat(inputs.bams[i][1]); } return output; }
            tumor_bam:
                valueFrom: ${ var output = []; for (var i=0; i<inputs.bams.length; i++) { output=output.concat(inputs.bams[i][0]); } return output; }
            genome:
                valueFrom: ${ return inputs.runparams.genome }
            bed: beds
            normal_sample_name:
                valueFrom: ${ var output = []; for (var i=0; i<inputs.pair.length; i++) { output=output.concat(inputs.pair[i][1].ID); } return output; }
            tumor_sample_name:
                valueFrom: ${ var output = []; for (var i=0; i<inputs.pair.length; i++) { output=output.concat(inputs.pair[i][0].ID); } return output; }
            dbsnp: dbsnp
            cosmic: cosmic
            mutect_dcov:
                valueFrom: ${ return inputs.runparams.mutect_dcov }
            mutect_rf:
                valueFrom: ${ return inputs.runparams.mutect_rf }
            refseq:
                valueFrom: ${ return inputs.db_files.refseq }
            hotspot_vcf:
                valueFrom: ${ return inputs.db_files.hotspot_vcf }
            ref_fasta:
                valueFrom: ${ return inputs.db_files.ref_fasta }
            facets_pcval:
                valueFrom: ${ return inputs.runparams.facets_pcval }
            facets_cval:
                valueFrom: ${ return inputs.runparams.facets_cval }
            facets_snps:
                valueFrom: ${ return inputs.db_files.facets_snps }
            tmp_dir:
                valueFrom: ${ return inputs.runparams.tmp_dir; }
            complex_tn:
                valueFrom: ${ return inputs.runparams.complex_tn; }
            complex_nn:
                valueFrom: ${ return inputs.runparams.complex_nn; }
        scatter: [pair,bed,normal_bam,tumor_bam,normal_sample_name,tumor_sample_name]
        scatterMethod: dotproduct
        out: [combine_vcf, annotate_vcf, facets_png, facets_txt_hisens, facets_txt_purity, facets_out, facets_rdata, facets_seg, mutect_vcf, mutect_callstats, vardict_vcf, facets_counts, vardict_norm_vcf, mutect_norm_vcf]