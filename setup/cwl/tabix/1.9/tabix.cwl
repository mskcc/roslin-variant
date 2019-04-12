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
  doap:name: cmo-bcftools.concat
  doap:revision: 1.9
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
- "htslib"
- --version
- "1.9"
- --cmd
- "tabix"
id: tabix

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing: [ $(inputs.input_vcf) ]
  ResourceRequirement:
    ramMin: 80000
    coresMin: 1

doc: |
  Index vcf files

inputs:

  input_vcf:
    type: File
    doc: VCF to tabix index
    inputBinding:
      position: 1

  zero:
    type: ["null", boolean]
    doc: coordinates are zero-based
    inputBinding:
      prefix: --zero-based

  being:
    type: ["null", string]
    doc: column number for region start [4]
    inputBinding:
      prefix: --begin

  comment:
    type: ["null", string]
    doc: skip comment lines starting with CHAR [null]
    inputBinding:
      prefix: --comment

  csi:
    type: ["null", boolean]
    doc: generate CSI index for VCF (default is TBI)
    inputBinding:
      prefix: --csi

  end:
    type: ["null", string]
    doc: column number for region end (if no end, set INT to -b) [5]
    inputBinding:
      prefix: --end

  being:
    type: ["null", string]
    doc: column number for region start [4]
    inputBinding:
      prefix: --begin

  force:
    type: ["null", boolean]
    doc: overwrite existing index without asking
    inputBinding:
      prefix: --force

  min_shift:
    type: ["null", string]
    doc: set minimal interval size for CSI indices to 2^INT [14]
    inputBinding:
      prefix: --min-shift

  preset:
    type: ["null", string]
    doc: gff, bed, sam, vcf
    inputBinding:
      prefix: --preset

  sequence:
    type: ["null", string]
    doc: column number for sequence names (suppressed by -p) [1]
    inputBinding:
      prefix: --sequence

  skip_lines:
    type: ["null", string]
    doc: skip first INT lines [0]
    inputBinding:
      prefix: --skip-lines

  print_header:
    type: ["null", boolean]
    doc: print also the header lines
    inputBinding:
      prefix: --print-header

  only_header:
    type: ["null", boolean]
    doc: print only the header lines
    inputBinding:
      prefix: --only-header

  list_chroms:
    type: ["null", boolean]
    doc: list chromosome names
    inputBinding:
      prefix: --list-chroms

  reheader:
    type: ["null", File]
    doc: replace the header with the content of FILE
    inputBinding:
      prefix: --reheader

  regions:
    type: ["null", File]
    doc: restrict to regions listed in the file
    inputBinding:
      prefix: --regions

  targets:
    type: ["null", File]
    doc: similar to -R but streams rather than index-jumps
    inputBinding:
      prefix: --targets

outputs:
  tabix_output_file:
    type: File
    outputBinding:
      glob: "*.gz"
    secondaryFiles: [".tbi",".csi"]
