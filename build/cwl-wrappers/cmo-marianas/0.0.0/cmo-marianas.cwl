cwlVersion: cwl:v1.0

#!/usr/bin/env/cwl-runner

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
  doap:name: innovation-umi-trimming
  doap:revision: 0.5.0
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Ian Johnson
    foaf:mbox: mailto:johnsoni@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Ian Johnson
    foaf:mbox: mailto:johnsoni@mskcc.org

class: CommandLineTool

baseCommand: [cmo_process_loop_umi_fastq]

arguments: ["-server", "-Xms8g", "-Xmx8g", "-cp"]

doc: |

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 4
    coresMin: 1
  None

inputs:
  r1_fastq:
    type: File
    inputBinding:
      prefix: --r1_fastq
    secondaryFiles:
    - ${return self.location.replace("_R1_", "_R2")}
    - ${return self.location.replace(/(.*)(\/.*$)/, "$1/SampleSheet.csv")}

  umi_length:
    type: string
    inputBinding:
      prefix: --umi_length

  output_project_folder:
    type: string
    inputBinding:
      prefix: --output_project_folder

outputs:
  processed_fastq_1:
    type: File
    outputBinding:
      glob: $(inputs.r1_fastq)

  processed_fastq_2:
    type: File
    outputBinding:
      glob: $(inputs.r2_fastq)

#  composite_umi_frequencies:
#    type: File
#    outputBinding:
#      glob: composite-umi-frequencies.txt

  info:
    type: File
    outputBinding:
      glob: info.txt

#   sample_sheet:
#     type: File
#     outputBinding:
#       glob: SampleSheet.csv

  umi_frequencies:
    type: File
    outputBinding:
      glob: umi-frequencies.txt