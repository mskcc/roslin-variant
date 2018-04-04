#!/usr/bin/env cwl-runner

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
  doap:name: cmo-ppflag-fixer
  doap:revision: 0.1.1
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Nikhil Kumar
    foaf:mbox: mailto:kumarn1@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Nikhil Kumar
    foaf:mbox: mailto:kumarn1@mskcc.org

# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_ppflag-fixer --generate_cwl_tool
# Help: $ cmo_ppflag --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- non-cmo.sh
- --tool
- "htstools"
- --version
- "0.1.1"
- --language_version
- "default"
- --language
- "bash"
- ppflag-fixer

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 8
    coresMin: 1


doc: |
  run ppflag-fixer

inputs:
  max_tlen:
    type: ['null', string]
    doc: Sets a maximum bound of LENGTH on all fragments;any greater and they won't
      be marked as properpair.
    inputBinding:
      prefix: --max-tlen

  progress:
    type: ['null', boolean]
    default: false
    doc: Keep track of progress through the file. Thisrequires the file to be indexed.
    inputBinding:
      prefix: --progress

  input_file:
    type: File

    doc: Bam file
    inputBinding:
      position: 1

  output_file:
    type: string

    doc: output file
    inputBinding:
      position: 2

  stderr:
    type: ['null', string]
    doc: log stderr to file
    inputBinding:
      prefix: --stderr

  stdout:
    type: ['null', string]
    doc: log stdout to file
    inputBinding:
      prefix: --stdout


outputs:
  out_file:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.output_file)
            return inputs.output_file;
          return null;
        }
