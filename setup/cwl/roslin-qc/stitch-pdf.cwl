
cwlVersion: cwl:v1.0

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement: 
    listing: $(inputs.data_dir.listing)
 
  ResourceRequirement:
    ramMin: 8000
    coresMin: 1

class: CommandLineTool
baseCommand: 
- java
- -jar
- "/ifs/work/bolipatc/sandbox_branch/roslin-pipelines/variant/build_387/workspace/qcpdf/QCPDF.jar"

inputs:

  data_dir:
    type: Directory

  bin:
    type: string
    default: "/ifs/work/bolipatc/sandbox_branch/roslin-pipelines/variant/build_387/workspace/qcpdf"

  request_file:
    type: File
    inputBinding:
      prefix: -rf

  version:
    type: float
    default: 1.0
    inputBinding:
      prefix: -v

  images_dir:
    type: [ 'null', string ]
    default: "."
    inputBinding:
      prefix: -d

  output_directory:
    type: [ 'null', string ]
    default: "." 
    inputBinding:
      prefix: -o

  cov_warn_threshold:
    type: [ 'null', int ]
    default: 200
    inputBinding:
      prefix: -cw

  cov_fail_threshold:
    type: [ 'null', int ]
    default: 50
    inputBinding:
      prefix: -cf

  pl:
    type: string
    default: "Variants"
    inputBinding:
      prefix: -pl

outputs:
  compiled_pdf:
    type: Directory 
    basename: "compiled_pdf"
    outputBinding:
      glob: "."
