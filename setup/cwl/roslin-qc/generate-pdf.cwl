

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
  doap:name: cmo-bcftools.concat
  doap:revision: 1.3.1
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
baseCommand: [ 'qcPDF.pl' ]

inputs:

  version:
    type: [ 'null', string ]
    default: "1.0"
    inputBinding:
      prefix: -version

  file_prefix:
    type: string
    inputBinding:
      prefix: -pre

  request_file:
    type: File
    inputBinding:
      prefix: -request

  path:
    type: string
    default: "."
    inputBinding:
      prefix: -path

  log:
    type: string
    default: "qcPDF.log"
    inputBinding:
      prefix: -log

  minor_contam_threshold:
    type: [ 'null', float ]
    default: 0.02
    inputBinding:
      prefix: -minor_contam_threshold

  major_contam_threshold:
    type: [ 'null', float ]
    default: 0.05
    inputBinding:
      prefix: -major_contam_threshold

  duplication_threshold:
    type: ['null', int ]
    default: 80
    inputBinding:
      prefix: -dup_rate_threshold

  cov_warn_threshold:
    type: [ 'null', int ]
    default: 200
    inputBinding:
      prefix: -cov_warn_threshold

  cov_fail_threshold:
    type: [ 'null', int ]
    default: 50
    inputBinding:
      prefix: -cov_fail_threshold

outputs:
  output:
    type:
      type: array
      items: File
    outputBinding:
      glob: |
        ${
            return "*";
        }
