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
  doap:name: basic-filtering.somaticIndelDetector
  doap:revision: 0.2.0
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
    foaf:name: Cyriac Kandoth
    foaf:mbox: mailto:ckandoth@gmail.com
  - class: foaf:Person
    foaf:name: Ronak H. Shah
    foaf:mbox: mailto:shahr2@mskcc.org
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand: [tool.sh]
label: basic-filtering-somaticIndelDetector

arguments:
- valueFrom: "basic-filtering"
  prefix: --tool
  position: 0
- valueFrom: "0.2.0"
  prefix: --version
  position: 0
- valueFrom: "default"
  prefix: --language_version
  position: 0
- valueFrom: "bash"
  prefix: --language
  position: 0
- valueFrom: "sid"
  prefix: --cmd
  position: 0

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 10000
    coresMin: 2


doc: |
  Filter indels from the output of SomaticIndelDetector in GATK v2.3-9

inputs:
  verbose:
    type: ['null', boolean]
    default: false
    doc: More verbose logging to help with debugging
    inputBinding:
      prefix: --verbose

  inputVcf:
    type: 
    - string
    - File
    doc: Input SomaticIndelDetector vcf file which needs to be filtered
    inputBinding:
      prefix: --inputVcf

  inputTxt:
    type: 
    - string
    - File
    doc: Input SomaticIndelDetector txt file which needs to be filtered
    inputBinding:
      prefix: --inputTxt

  tsampleName:
    type: string
    doc: Name of the tumor Sample
    inputBinding:
      prefix: --tsampleName

  dp:
    type: ['null', int]
    default: 5
    doc: Tumor total depth threshold
    inputBinding:
      prefix: --totaldepth

  ad:
    type: ['null', int]
    default: 3
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
      prefix: --variantfraction

  hotspotVcf:
    type:
    - 'null'
    - string
    - File
    doc: Input vcf file with hotspots that skip VAF ratio filter
    inputBinding:
      prefix: --hotspotVcf

  outdir:
    type: ['null', string]
    doc: Full Path to the output dir.
    inputBinding:
      prefix: --outDir


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
          if (inputs.inputTxt)
            return inputs.inputTxt.basename.replace(".txt","_STDfilter.txt");
          return null;
        }
