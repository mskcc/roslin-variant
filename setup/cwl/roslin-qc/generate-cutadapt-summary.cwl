

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
  doap:name: generate-cutadapt-summary
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

cwlVersion: cwl:v1.0

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
- merge_cut_adapt_stats
id: generate-cutadapt-summary.cwl
inputs:

  clstats1:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: File

    inputBinding:
      prefix: --clstats1

  clstats2:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: File
    inputBinding:
      prefix: --clstats2

  pairing_file:
    type: File
    inputBinding:
      prefix: --pairing_file


  output_filename:
    type: string
    inputBinding:
      prefix: --output

outputs:
  output:
    type: File
    outputBinding:
      glob: |
        ${
            return inputs.output_filename;
        }
