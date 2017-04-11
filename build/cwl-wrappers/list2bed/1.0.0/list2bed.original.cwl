#!/usr/bin/env cwl-runner
# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ list2bed.py --generate_cwl_tool
# Help: $ list2bed.py --help_arg2cwl

cwlVersion: "cwl:v1.0"

class: CommandLineTool
baseCommand: ['/opt/common/CentOS_6-dev/list2bed/1.0.0/list2bed.py']
requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 2
    coresMin: 1


doc: |
  None

inputs:

  input_file:
    type:
      - string
      - File
      - type: array
        items: string
    doc: picard interval list
    inputBinding:
      prefix: --input_file

  output_file:
    type: string

    doc: output bed file
    inputBinding:
      prefix: --output_file

  no_sort:
    type: ["null", string]
    default: store_false
    doc: sort bed file output
    inputBinding:
      prefix: --no_sort


outputs:
  output_file:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.output_file)
            return inputs.output_file;
          return null;
        }



