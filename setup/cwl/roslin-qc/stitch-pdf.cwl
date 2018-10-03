#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- file:///ifs/work/pi/roslin-test/targeted-variants/326/roslin-core/2.0.5/schemas/dcterms.rdf
- file:///ifs/work/pi/roslin-test/targeted-variants/326/roslin-core/2.0.5/schemas/foaf.rdf
- file:///ifs/work/pi/roslin-test/targeted-variants/326/roslin-core/2.0.5/schemas/doap.rdf

doap:release:
- class: doap:Version
  doap:name: stitch-pdf
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
  InitialWorkDirRequirement: 
    listing: $(inputs.data_dir.listing)
 
  ResourceRequirement:
    ramMin: 8000
    coresMin: 1

class: CommandLineTool
baseCommand: 
- java
- -jar
- QCPDF.jar
id: stitch-pdf

inputs:

  data_dir:
    type: Directory

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
    type: File
    outputBinding:
      glob: "*.pdf"
 
