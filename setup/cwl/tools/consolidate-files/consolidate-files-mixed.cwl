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
  doap:name: consolidate-files-mixed
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
id: consolidate-files-mixed

requirements:
  - class: InlineJavascriptRequirement

inputs:

  output_directory_name: string

  files:
    type:
      type: array
      items: File
    default: []

  directories:
    type:
      type: array
      items: Directory
    default: []

outputs:

  directory:
    type: Directory

# This tool returns a Directory object,
# which holds all output files from the list
# of supplied input files
expression: |
  ${
    function addFile(input_file_list) {
      var output_file_list = [];
      for (var i = 0; i < input_file_list.length; i++) {
        var input_file = input_file_list[i];
        if ( input_file["class"] == "File" ){
          output_file_list.push(input_file);
        }
        else if ( input_file["class"] == "Directory" ){
          output_file_list = output_file_list.concat(addDirectory([input_file]));
        }
      }
      return output_file_list;
    }

    function addDirectory(input_directory_list) {
      var output_file_list = [];
      for (var i = 0; i < input_directory_list.length; i++) {
         for (var j = 0; j < input_directory_list[i].listing.length; j++) {
             var item = input_directory_list[i].listing[j];
             output_file_list = output_file_list.concat(addFile([item]))
         }
      }
      return output_file_list;
    }

    var output_files = [];
    var output_files_trimmed = [];
    var output_file_basename_dict = {};
    output_files = output_files.concat(addFile(inputs.files));
    output_files = output_files.concat(addDirectory(inputs.directories));
    console.log(output_files);

    for (var i = 0; i < output_files.length; i++) {
      var output_file =  output_files[i];
      console.log(output_file);
      var output_file_basename = output_file['basename'];
      console.log(output_file_basename);
      if ( !(output_file_basename in output_file_basename_dict)){
        output_file_basename_dict[output_file_basename] = null;
        output_files_trimmed.push(output_file);
      }

    }


    return {
      'directory': {
        'class': 'Directory',
        'basename': inputs.output_directory_name,
        'listing': output_files_trimmed
      }
    };
  }
