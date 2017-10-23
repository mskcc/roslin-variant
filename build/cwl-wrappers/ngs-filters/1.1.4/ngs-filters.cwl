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
  doap:name: ngs-filters
  doap:revision: 1.1.4
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
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ run_ngs-filters.py --generate_cwl_tool
# Help: $ run_ngs --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- sing.sh
- ngs-filters
- 1.1.4

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 10
    coresMin: 4 

doc: |
  This tool helps to tag hotspot events

inputs:
  verbose:
    type: ['null', boolean]
    default: false
    doc: make lots of noise
    inputBinding:
      prefix: --verbose

  inputMaf:
    type: 

    - File
    doc: Input maf file which needs to be tagged
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

  NormalPanelMaf:
    type:
    - 'null'
    - string
    - File
    doc: Path to fillout maf file of panel of standard normals
    inputBinding:
      prefix: --normal-panel-maf

  FFPEPoolMaf:
    type:
    - 'null'
    - string
    - File
    doc: Path to fillout maf file for FFPE artifacts
    inputBinding:
      prefix: --ffpe_pool_maf

  NormalCohortMaf:
    type:
    - 'null'
    - string
    - File
    doc: Path to fillout maf file of cohort normals
    inputBinding:
      prefix: --normal-cohort-maf

  NormalCohortSamples:
    type: ['null', string]
    doc: File with list of normal samples
    inputBinding:
      prefix: --normalSamplesFile

  inputHSP:
    type:
    - 'null'
    - string
    - File
    doc: Input txt file which has hotspots
    inputBinding:
      prefix: --input-hotspot


outputs:
  output:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.outputMaf)
            return inputs.outputMaf;
          return null;
        }
