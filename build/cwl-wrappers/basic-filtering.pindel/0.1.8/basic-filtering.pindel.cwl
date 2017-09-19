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
  doap:name: basic-filtering.pindel
  doap:revision: 0.1.8
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
# To generate again: $ filter_pindel.py --generate_cwl_tool
# Help: $ filter_pindel.py --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- sing.sh
- basic-filtering
- 0.1.7
- pindel

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 10
    coresMin: 2


doc: |
  Filter indels from the output of pindel v0.2.5a7

inputs:
  verbose:
    type: ['null', boolean]
    default: true
    doc: make lots of noise
    inputBinding:
      prefix: --verbose

  inputVcf:
    type: 

      - string
      - File
    doc: Input vcf freebayes file which needs to be filtered
    inputBinding:
      prefix: --inputVcf

  tsampleName:
    type: string

    doc: Name of the tumor Sample
    inputBinding:
      prefix: --tsampleName

  dp:
    type: ['null', int]
    default: 0
    doc: Tumor total depth threshold
    inputBinding:
      prefix: --totaldepth

  ad:
    type: ['null', int]
    default: 5
    doc: Tumor allele depth threshold
    inputBinding:
      prefix: --alleledepth

  tnr:
    type: ['null', int]
    default: 5
    doc: Tumor-Normal variant frequency ratio threshold
    inputBinding:
      prefix: --tnRatio

  vf:
    type: ['null', float]
    default: 0.01
    doc: Tumor variant frequency threshold
    inputBinding:
      prefix: --variantfrequency

  outdir:
    type: ['null', string]
    doc: Full Path to the output dir.
    inputBinding:
      prefix: --outDir

  min:
    type: ['null', int]
    default: 0
    doc: Minimum length of the indels
    inputBinding:
      prefix: --min_var_len

  max:
    type: ['null', int]
    default: 2000
    doc: Max length of the indels
    inputBinding:
      prefix: --max_var_len

  hotspotVcf:
    type:
    - 'null'
    - string
    - File
    doc: Input bgzip / tabix indexed hotspot vcf file to used for filtering
    inputBinding:
      prefix: --hotspotVcf


outputs:
  vcf:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.inputVcf)
            return inputs.inputVcf.basename.replace(".vcf","_STDfilter.vcf");
          return null;
        }
  txt:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.inputVcf)
            return inputs.inputVcf.basename.replace(".vcf","_STDfilter.txt");
          return null;
        }
