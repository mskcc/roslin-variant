    

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
label: format-maf
requirements:
    MultipleInputFeatureRequirement: {}
    ScatterFeatureRequirement: {}
    SubworkflowFeatureRequirement: {}
    InlineJavascriptRequirement: {}
    StepInputExpressionRequirement: {}

inputs:

    input_maf:
        type: File

outputs:
    portal_file:
        type: File
        outputSource: portal_format_output/portal_formatted

steps:
    formatting_remove_comments:
        in:
            input_maf: input_maf
            output_filename:
                valueFrom: ${ return inputs.input_maf.basename.replace(".maf", ".grepped.txt"); }
        out: [ comment_removed ]
        run:
            class: CommandLineTool
            baseCommand: ["grep", "^[^#;]"]
            stdout: $(inputs.output_filename)
            inputs:
                input_maf:
                    type: File
                    inputBinding:
                        position: 1
                output_filename: string
            outputs:
                comment_removed:
                    type: stdout
    extract_columns:
        in:
            grepped_file: formatting_remove_comments/comment_removed
            output_filename:
                 valueFrom: ${ return inputs.grepped_file.basename.replace(".grepped.txt", ".extracted.txt"); }
        out: [ extracted_file ]
        run:
            class: CommandLineTool
            baseCommand: [] 

            arguments:
                - awk
                - -F
                - "\t"
                - 'NR==1 { for(i=1;i<=NF;i++){ f[$i]=i } print "Hugo_Symbol\\tEntrez_Gene_Id\\tCenter\\tTumor_Sample_Barcode\\tFusion\\tMethod\\tFrame" } NR>1 { print \$(f["Hugo_Symbol"])"\\t"\$(f["Entrez_Gene_Id"])"\\t"\$(f["Center"])"\\t"\$(f["Tumor_Sample_Barcode"])"\\t"\$(f["Fusion"])"\\t"\$(f["Method"])"\\t"\$(f["Frame"])}' 
            stdout: $(inputs.output_filename)
            inputs:
                grepped_file:
                    type: File
                    inputBinding:
                        position: 1
                output_filename: string
            outputs:
                extracted_file:
                    type: stdout
    add_two_columns: # RNA_support and no, DNA_support and yes
        in:
            extracted_file: extract_columns/extracted_file
            output_filename:
                 valueFrom: ${ return inputs.extracted_file.basename.replace(".extracted.txt", ".columns_added.txt"); }
        out: [ columns_added ]
        run:
            class: CommandLineTool
            baseCommand: ["sed", "1s/$/\\tDNA_support\\tRNA_support/;2,$s/$/\\tyes\\tno/"]
            stdout: $(inputs.output_filename)
            inputs:
                extracted_file:
                    type: File
                    inputBinding:
                        position: 1
                output_filename: string
            outputs:
                columns_added:
                    type: stdout
    portal_format_output:
        in:
            sed_file: add_two_columns/columns_added
            output_filename:
                 valueFrom: ${ return inputs.sed_file.basename.replace(".columns_added.txt", ".portal.txt"); }
        out: [ portal_formatted ]
        run:
            class: CommandLineTool
            baseCommand: [] 

            arguments:
                - awk
                - -F
                - "\t"
                - 'NR==1 { for(i=1;i<=NF;i++){ f[$i]=i } } { print \$(f["Hugo_Symbol"])"\\t"\$(f["Entrez_Gene_Id"])"\\t"\$(f["Center"])"\\t"\$(f["Tumor_Sample_Barcode"])"\\t"\$(f["Fusion"])"\\t"\$(f["DNA_support"])"\\t"\$(f["RNA_support"])"\\t"\$(f["Method"])"\\t"\$(f["Frame"])}'
    
            stdout: $(inputs.output_filename)
            inputs:
                sed_file:
                    type: File
                    inputBinding:
                        position: 1
                output_filename: string
            outputs:
                portal_formatted:
                    type: stdout
