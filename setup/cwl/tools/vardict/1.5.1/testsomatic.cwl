$namespaces:
  dct: http://purl.org/dc/terms/
  doap: http://usefulinc.com/ns/doap#
  foaf: http://xmlns.com/foaf/0.1/
$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#
baseCommand:
- /usr/bin/vardict/testsomatic.R
class: CommandLineTool
cwlVersion: v1.0
dct:contributor:
- class: foaf:Organization
  foaf:member:
  - class: foaf:Person
    foaf:mbox: mailto:ivkovics@mskcc.org
    foaf:name: Sinisa Ivkovic,
  foaf:name: MSKCC
dct:creator:
- class: foaf:Organization
  foaf:member:
  - class: foaf:Person
    foaf:mbox: mailto:ivkovics@mskcc.org
    foaf:name: Sinisa Ivkovic,
  foaf:name: MSKCC
doap:release:
- class: doap:Version
  doap:name: Testsomatic
  doap:revision: 1.5.1
- class: doap:Version
  doap:name: MSK-App
  doap:revision: 1.0.0
id: testsomatic
inputs:
- id: input_vardict
  type: File
label: testsomatic
outputs:
- id: output_var
  outputBinding:
    glob: output_testsomatic.var
  type: File?
requirements:
- class: DockerRequirement
  dockerPull: mskcc/roslin-variant-vardict:1.5.1
- class: InlineJavascriptRequirement
stdin: $(inputs.input_vardict.path)
stdout: output_testsomatic.var
