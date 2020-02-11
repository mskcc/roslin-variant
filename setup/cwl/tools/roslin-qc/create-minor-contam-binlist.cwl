#
#/usr/bin/env cwl-runner

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
  doap:name: create-minor-contam-binlist.cwl
  doap:revision: 0.2
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: C. Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: C. Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org

cwlVersion: v1.0

class: CommandLineTool
baseCommand:
- tool.sh
- --tool
- "roslin-qc"
- --version
- "0.6.4"
- --cmd
- create_minor_contam_binlist
id: create-minor-contam-binlist

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 16000
    coresMin: 1

doc: |
  None

inputs:

  minor_contam_file:
    type: File
    inputBinding:
      prefix: --minorcontam

  project_prefix:
    type: string
    inputBinding:
      prefix: --project_prefix

  fp_summary:
    type: File
    inputBinding:
      prefix: --fpsummary

  min_cutoff:
    type: float
    inputBinding:
      prefix: --min_cutoff

outputs:
  minor_contam_freqlist:
    type: File
    outputBinding:
      glob: |
        ${
          return inputs.project_prefix + "_MinorContamFreqList.txt";
        }
