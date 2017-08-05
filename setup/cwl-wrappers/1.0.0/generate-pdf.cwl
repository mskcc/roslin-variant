#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ generate_pdf.py --generate_cwl_tool
# Help: $ generate_pdf.py --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['cmo_qcpdf']

doc: |
  None

inputs:
  
  gcbias_files:
    type:
      type: array
      items: File
    inputBinding:
      prefix: --gcbias-files 

  mdmetrics_files:
    type:
      type: array
      items:
        type: array
        items: File
  
    inputBinding:
      prefix: --mdmetrics-files 

  insertsize_files:
    type: 
      type: array
      items: File
  
    inputBinding:
      prefix: --insertsize-files 

  hsmetrics_files:
    type:
      type: array
      items: File
  
  
    inputBinding:
      prefix: --hsmetrics-files 

  qualmetrics_files:
    type:
      type: array
      items: File
  
    inputBinding:
      prefix: --qualmetrics-files 

  fingerprint_files:
    type:
      type: array
      items: File
   
    inputBinding:
      prefix: --fingerprint-files 

  trimgalore_files:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: 
            type: array
            items: File
    inputBinding:
      prefix: --trimgalore-files 

  file_prefix:
    type: string
    inputBinding:
      prefix: --file-prefix 

  fp_genotypes:
    type: File
    inputBinding:
      prefix: --fp-genotypes 

  pairing_file:
    type: File
    inputBinding:
      prefix: --pairing-file 

  grouping_file:
    type: File
    inputBinding:
      prefix: --grouping-file 

  request_file:
    type: File
    inputBinding:
      prefix: --request-file 


outputs:
  qc_files:
    type: 
      type: array
      items: File
    outputBinding:
      glob: | 
        ${
            return inputs.file_prefix + "*";
        }
