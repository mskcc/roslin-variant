

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
  doap:name: generate-qual-files
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

cwlVersion: v1.0

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 8000
    coresMin: 1

class: CommandLineTool
baseCommand:
- tool.sh
- --tool
- "roslin-qc"
- --version
- "0.6.0"
- --cmd
- merge_mean_quality_histograms
id: generate-qual-files
inputs:
  files:
    type: 
      type: array
      items: File
    inputBinding:
      prefix: --files
  rqual_output_filename:
    type: string
    inputBinding:
      prefix: --rqual_outfile
  oqual_output_filename:
    type: string
    inputBinding:
      prefix: --oqual_outfile

outputs:
  rqual_output:
    type: File
    outputBinding:
      glob: |
        ${
            return inputs.rqual_output_filename;
        }

  oqual_output:
    type: File
    outputBinding:
      glob: |
        ${
            return inputs.oqual_output_filename;
        }
