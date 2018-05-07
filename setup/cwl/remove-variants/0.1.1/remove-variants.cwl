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
  doap:name: remove-variants
  doap:revision: 0.1.1
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Ronak H. Shah
    foaf:mbox: mailto:shahr2@mskcc.org
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ remove_variants.py --generate_cwl_tool
# Help: $ remove_variants.py --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand: [tool.sh]

arguments:
- valueFrom: "remove-variants"
  prefix: --tool
  position: 0
- valueFrom: "0.1.1"
  prefix: --version
  position: 1
- valueFrom: "default"
  prefix: --language_version
  position: 2
- valueFrom: "python"
  prefix: --language
  position: 3

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 8
    coresMin: 1

doc: |
  Remove snps/indels from the output maf where a complex variant is called

inputs:

  verbose:
    type: ['null', boolean]
    default: false
    doc: make lots of noise
    inputBinding:
      prefix: --verbose

  inputMaf:
    type: 

    - string
    - File
    doc: Input maf file which needs to be fixed
    inputBinding:
      prefix: --input-maf

  outputMaf:
    type: string

    doc: Output maf file name
    inputBinding:
      prefix: --output-maf

  outdir:
    type: ['null', string]
    doc: Full Path to the output dir.
    inputBinding:
      prefix: --outDir


outputs:
  maf:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.outputMaf )
            return inputs.outputMaf;
          return null;
        }
