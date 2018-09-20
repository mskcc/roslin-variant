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
  doap:name: cmo-fillout
  doap:revision: 1.2.1
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
# To generate again: $ cmo_fillout -o FILENAME --generate_cwl_tool
# Help: $ cmo_fillout  --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand: [cmo_fillout]
label: cmo-fillout

arguments:
- valueFrom: "1.2.1"
  prefix: --version
  position: 0

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 32000
    coresMin: 2

doc: |
  Fillout allele counts for a MAF file using GetBaseCountsMultiSample on BAMs

inputs:
  maf:
    type: File

    doc: MAF file on which to fillout
    inputBinding:
      prefix: --maf

  bams:
    type:
      type: array
      items: File
    doc: BAM files to fillout with
    inputBinding:
      prefix: --bams
    secondaryFiles:
    - ^.bai

  genome:
    type: string
    doc: Reference assembly of BAM files, e.g. hg19/grch37/b37
    inputBinding:
      prefix: --genome

  output:
    type: ['null', string]
    doc: Filename for output of raw fillout data in MAF/VCF format
    inputBinding:
      prefix: --output

  portal_output:
    type: ['null', string]
    doc: Filename for a portal-friendly output MAF
    inputBinding:
      prefix: --portal-output

  fillout:
    type: ['null', string]
    doc: Precomputed fillout file from GBCMS (using this skips GBCMS)
    inputBinding:
      prefix: --fillout

  n_threads:
    type:
    - 'null'
    - int
    default: 4
    doc: Multithreaded GBCMS
    inputBinding:
      prefix: --n_threads

  output_format:
    type: string
    doc: Output format MAF(1) or tab-delimited with VCF based coordinates(2)
    inputBinding:
      prefix: --format

outputs:

  fillout_out:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.output)
            return inputs.output;
          else
            return inputs.maf.basename.replace(".maf", ".fillout");
        }

  portal_fillout:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.portal_output)
            return inputs.portal_output;
          else
            return inputs.maf.basename.replace(".maf", ".fillout.portal.maf");
        }
