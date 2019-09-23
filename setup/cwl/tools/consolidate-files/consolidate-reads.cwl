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
  doap:name: consolidate-reads
  doap:revision: 1.0.0
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Ian Johnson
    foaf:mbox: mailto:johnsoni@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org

cwlVersion: v1.0

class: ExpressionTool
id: consolidate-reads

requirements:
  - class: InlineJavascriptRequirement

inputs:

  reads_dir: Directory

outputs:

  r1: File[]
  r2: File[]

expression: |
  ${
    var r1_files = [];
    var r2_files = [];

    for (var i = 0; i < inputs.reads_dir.listing.length; i++) {
      var current_file_obj = inputs.reads_dir.listing[i];
      if (current_file_obj.class == "Directory"){
        for (var j = 0; j < current_file_obj.listing.length; j++) {
          var current_fastq = current_file_obj.listing[j];
          if ( current_fastq.basename.includes("_R1_")){
            r1_files.push(current_fastq);
          }
          else if ( current_fastq.basename.includes("_R2_")){
            r2_files.push(current_fastq);
          }
        }
      }
    }

    return {
      'r1': r1_files,
      'r2': r2_files
    };
  }
