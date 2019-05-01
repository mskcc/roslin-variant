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
  doap:name: structural-variants
  doap:revision: 1.0.0
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org
  - class: foaf:Person
    foaf:name: Nikhil Kumar
    foaf:mbox: mailto:kumarn1@mskcc.org
  - class: foaf:Person
    foaf:name: Christopher Harris
    foaf:mbox: mailto:harrisc2@mskcc.org

cwlVersion: v1.0

class: Workflow
id: structural-variants-pair
requirements:
    MultipleInputFeatureRequirement: {}
    ScatterFeatureRequirement: {}
    SubworkflowFeatureRequirement: {}
    InlineJavascriptRequirement: {}
    StepInputExpressionRequirement: {}

inputs:
    tumor_bam: File
    normal_bam: File
    genome: string
    normal_sample_name: string
    tumor_sample_name: string
    ref_fasta: string
    vep_path: string
    custom_enst: string
    vep_data: string
    delly_type: string[]
    tmp_dir: string
outputs:
    delly_sv:
        type: File[]
        secondaryFiles:
            - ^.bcf.csi
        outputSource: call_sv_by_delly/delly_sv
    delly_filtered_sv:
        type: File[]
        outputBinding:
            glob: '*.pass.bcf'
        secondaryFiles:
            - ^.bcf.csi
        outputSource: call_sv_by_delly/delly_filtered_sv
    merged_file:
        type: File
        outputSource: merge_with_bcftools/concat_vcf_output_file
    merged_file_unfiltered:
        type: File
        outputSource: merge_with_bcftools_unfiltered/concat_vcf_output_file
    maf_file:
        type: File
        outputSource: convert_vcf2maf/output
    portal_file:
        type: File
        outputSource: portal_format_output/portal_file
steps:
    index:
        run: ../../tools/cmo-index/1.0.0/cmo-index.cwl
        in:
            tumor: tumor_bam
            normal: normal_bam
        out: [tumor_bam, normal_bam]
    createTNPair:
        in:
           tumor_sample_name: tumor_sample_name
           normal_sample_name: normal_sample_name
           echoString:
               valueFrom: ${ return inputs.tumor_sample_name + "\ttumor\n" + inputs.normal_sample_name + "\tcontrol"; }
           output_filename:
               valueFrom: ${ return "tn_pair.txt"; }
        out: [ pairfile ]
        run:
            class: CommandLineTool
            baseCommand: ['echo', '-e']
            id: 'echo'
            stdout: $(inputs.output_filename)

            requirements:
                InlineJavascriptRequirement: {}
                MultipleInputFeatureRequirement: {}

            inputs:
                echoString:
                    type: string
                    inputBinding:
                        position: 1
                output_filename: string
            outputs:
                pairfile:
                    type: stdout
    call_sv_by_delly:
        scatter: [ delly_type ]
        scatterMethod: dotproduct
        in:
            tumor_bam: index/tumor_bam
            normal_bam: index/normal_bam
            normal_sample_name: normal_sample_name
            tumor_sample_name: tumor_sample_name
            genome: genome
            pairfile: createTNPair/pairfile
            delly_type: delly_type
        out: [ delly_sv , delly_filtered_sv ]
        run:
            class: Workflow
            inputs:
                tumor_bam:
                    type: File
                    secondaryFiles:
                        - .bai
                normal_bam:
                    type: File
                    secondaryFiles:
                        - .bai
                genome: string
                normal_sample_name: string
                tumor_sample_name: string
                delly_type: string
                pairfile: File
            outputs:
                delly_sv:
                    type: File
                    secondaryFiles:
                        - ^.bcf.csi
                    outputSource: delly_call/sv_file
                delly_filtered_sv:
                    type: File
                    outputBinding:
                        glob: '*.pass.bcf'
                    secondaryFiles:
                        - ^.bcf.csi
                    outputSource: delly_filter/sv_file
            steps:
                delly_call:
                    run: ../../tools/cmo-delly.call/0.7.7/cmo-delly.call.cwl
                    in:
                        t: delly_type
                        tumor_bam: tumor_bam
                        normal_bam: normal_bam
                        normal_sample_name: normal_sample_name
                        tumor_sample_name: tumor_sample_name
                        g: genome
                        o:
                            valueFrom: ${ return inputs.tumor_sample_name + "." + inputs.normal_sample_name +"." + inputs.t + ".bcf"; }
                    out: [ sv_file ]
                delly_filter:
                    run: ../../tools/cmo-delly.filter/0.7.7/cmo-delly.filter.cwl
                    in:
                        i: delly_call/sv_file
                        s: pairfile
                        t: delly_type
                        o:
                            valueFrom: ${ return inputs.i.basename.replace(".bcf", ".pass.bcf"); }
                    out: [ sv_file ]
    merge_with_bcftools_unfiltered:
        run: ../../tools/bcftools.concat/1.9/bcftools.concat.cwl
        in:
            tumor_sample_name: tumor_sample_name
            normal_sample_name: normal_sample_name
            allow_overlaps:
                valueFrom: ${ return true; }
            vcf_files_csi: call_sv_by_delly/delly_sv
            output:
                valueFrom: ${ return inputs.tumor_sample_name + "." + inputs.normal_sample_name + ".svs.vcf"; }
        out: [ concat_vcf_output_file ]
    merge_with_bcftools:
        run: ../../tools/bcftools.concat/1.9/bcftools.concat.cwl
        in:
            tumor_sample_name: tumor_sample_name
            normal_sample_name: normal_sample_name
            allow_overlaps:
                valueFrom: ${ return true; }
            vcf_files_csi: call_sv_by_delly/delly_filtered_sv
            output:
                valueFrom: ${ return inputs.tumor_sample_name + "." + inputs.normal_sample_name + ".svs.pass.vcf"; }
        out: [ concat_vcf_output_file ]
    convert_vcf2maf:
        run: ../../tools/cmo-vcf2maf/1.6.17/cmo-vcf2maf.cwl
        in:
            tmp_dir: tmp_dir
            vep_data: vep_data
            vep_path: vep_path
            vep_release:
                valueFrom: ${ return "86"; } # SVs have issues with vep 92 - moving to 86 for compatibility
            ref_fasta: ref_fasta
            custom_enst: custom_enst
            normal_id: normal_sample_name
            tumor_id: tumor_sample_name
            vcf_normal_id: normal_sample_name
            vcf_tumor_id: tumor_sample_name
            input_vcf: merge_with_bcftools/concat_vcf_output_file
            output_maf:
                valueFrom: $(inputs.input_vcf.basename.replace('vcf','vep.maf'))
        out: [ output ]
    portal_format_output:
        run: ../../tools/portal-formatting.cli/1.0.0/format-maf.cwl
        in:
            input_maf: convert_vcf2maf/output
        out: [ portal_file ]