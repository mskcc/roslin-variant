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
  doap:name: basic-filtering.complex
  doap:revision: 0.3
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

cwlVersion: v1.0

class: CommandLineTool
baseCommand:
- tool.sh
- --tool
- "basic-filtering"
- --version
- "default"
- --language_version
- "default"
- --language
- "bash"
- complex
label: basic-filtering-complex
requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 16000
    coresMin: 2


doc: |
  Given a VCF listing somatic events and a TN-pair of BAMS, apply a complex filter based on indels/soft-clipping noise

inputs:
  inputVcf:
    type:
    - string
    - File
    doc: Input VCF file
    inputBinding:
      prefix: --input-vcf

  refFasta:
    type:
    - string
    - File
    doc: Reference genome in fasta format
    inputBinding:
      prefix: --refFasta

  normal_bam:
    type: File
    doc: Normal Bam file
    inputBinding:
      prefix: --normal-bam

  tumor_bam:
    type: File
    doc: Tumor Bam file
    inputBinding:
      prefix: --tumor-bam

  tumor_id:
    type: ["null", string]
    doc: Tumor sample ID
    inputBinding:
      prefix: --tumor-id

  output_vcf:
    type: ["null", string]
    doc: Output VCF file
    inputBinding:
      prefix: --output-vcf

  flank_len:
    type: ["null", int]
    doc: Flanking bps around event to check for noise
    default: 50
    inputBinding:
      prefix: --flank-len

  mapping_qual:
    type: ["null", int]
    doc: Minimum mapping quality of noisy reads
    default: 20
    inputBinding:
      prefix: --mapping-qual

  nrm_noise:
    type: ["null", float]
    doc: Maximum allowed normal noise
    default: 0.1
    inputBinding:
      prefix: --nrm-noise

  tum_noise:
    type: ["null", float]
    doc: Maximum allowed tumor noise
    default: 0.2
    inputBinding:
      prefix: --tum-noise


outputs:
  vcf:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.output_vcf)
            return inputs.output_vcf;
          return null;
        }