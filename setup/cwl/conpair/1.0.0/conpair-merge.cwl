#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- file:///ifs/work/pi/roslin-test/targeted-variants/237/roslin-core/2.0.0/schemas/dcterms.rdf
- file:///ifs/work/pi/roslin-test/targeted-variants/237/roslin-core/2.0.0/schemas/foaf.rdf
- file:///ifs/work/pi/roslin-test/targeted-variants/237/roslin-core/2.0.0/schemas/doap.rdf

doap:release:
- class: doap:Version
  doap:name: conpair-merge.cwl
  doap:revision: 1.0.0
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Zuojian Tang
    foaf:mbox: mailto:tangz@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Zuojian Tang
    foaf:mbox: mailto:tangz@mskcc.org

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- non-cmo.sh
- --tool
- "conpair_merge"
- --version
- "1.0.0"
- --language_version
- "default"
- --language
- "python"

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 16
    coresMin: 1

doc: |
  None

inputs:
  pairing_file:
    type:
    - [File, string]
    doc: sample pairing file
    inputBinding:
      prefix: --pairing 

  cordlist:
    type:
      type: array
      items: File
    doc: Input concordance files
    inputBinding:
      prefix: --cordlist 

  tamilist:  
    type:
      type: array
      items: File  
    doc: Input contamination files
    inputBinding:
      prefix: --tamilist

outputs:
  concordance_txt:
    type: File
    outputBinding:
      glob: "concordance.txt"

  concordance_r:
    type: File
    outputBinding:
      glob: "concordance.R"

  concordance_pdf:
    type: File
    outputBinding:
      glob: "concordance.pdf"

  contamination_txt:
    type: File
    outputBinding:
      glob: "contamination.txt"

  contamination_r:
    type: File
    outputBinding:
      glob: "contamination.R"

  contamination_pdf:
    type: File
    outputBinding:
      glob: "contamination.pdf"
