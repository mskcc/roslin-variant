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
  doap:name: rename-directory
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

class: ExpressionTool

requirements:
  - class: InlineJavascriptRequirement

inputs:

  output_directory_name: string
  data_dir: Directory

outputs:

  directory:
    type: Directory

expression: |
  ${
    return {
      'directory': {
        'class': 'Directory',
        'basename': inputs.output_directory_name,
        'listing': inputs.data_dir.listing
      }
    };
  }
