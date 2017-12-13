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
  doap:name: cmo-vcf2maf
  doap:revision: 1.6.12
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
# To generate again: $ cmo_vcf2maf -o FILENAME --generate_cwl_tool
# Help: $ cmo_vcf2maf  --help_arg2cwl

cwlVersion: cwl:v1.0

class: CommandLineTool
baseCommand:
- cmo_vcf2maf
- --version
- 1.6.12

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 10
    coresMin: 4


doc: |
  None

inputs:
  vep_release:
    type:
    - 'null'
    - string
    default: '86'
    doc: Version of VEP and its cache to use
    inputBinding:
      prefix: --vep-release

  species:
    type:
    - 'null'
    - type: enum
      symbols: [homo_sapiens, mus_musculus]
    default: homo_sapiens
    doc: Species of variants in input
    inputBinding:
      prefix: --species

  ncbi_build:
    type:
    - 'null'
    - type: enum
      symbols: [GRCh37, GRCh38, GRCm38]
    default: GRCh37
    doc: Genome build of variants in input
    inputBinding:
      prefix: --ncbi-build

  ref_fasta:
    type: ['null', string]
    default: /ifs/depot/assemblies/H.sapiens/b37/b37.fasta
    doc: Reference FASTA file
    inputBinding:
      prefix: --ref-fasta

  maf_center:
    type: ['null', string]
    default: mskcc.org
    doc: Variant calling center to report in MAF
    inputBinding:
      prefix: --maf-center

  output_maf:
    type: ['null', string]
    doc: Path to output MAF file
    inputBinding:
      prefix: --output-maf

  max_filter_ac:
    type:
    - 'null'
    - int
    default: 10
    doc: Use tag common_variant if the filter-vcf reports a subpopulation AC higher
      than this
    inputBinding:
      prefix: --max-filter-ac

  min_hom_vaf:
    type:
    - 'null'
    - float
    default: 0.7
    doc: If GT undefined in VCF, minimum allele fraction to call a variant homozygous
    inputBinding:
      prefix: --min-hom-vaf

  remap_chain:
    type: ['null', string]
    doc: Chain file to remap variants to a different assembly before running VEP
    inputBinding:
      prefix: --remap-chain

  normal_id:
    type: ['null', string]
    default: NORMAL
    doc: Matched_Norm_Sample_Barcode to report in the MAF
    inputBinding:
      prefix: --normal-id

  custom_enst:
    type: ['null', string]
    default: /usr/bin/vcf2maf/data/isoform_overrides_at_mskcc
    doc: List of custom ENST IDs that override canonical selection
    inputBinding:
      prefix: --custom-enst

  vcf_normal_id:
    type: ['null', string]
    default: NORMAL
    doc: Matched normal ID used in VCF's genotype columns
    inputBinding:
      prefix: --vcf-normal-id

  vep_path:
    type: ['null', string]
    default: /usr/bin/vep/
    doc: Folder containing variant_effect_predictor.pl
    inputBinding:
      prefix: --vep-path

  vep_data:
    type: ['null', string]
    default: /opt/common/CentOS_6-dev/vep/v86/
    doc: VEP's base cache/plugin directory
    inputBinding:
      prefix: --vep-data

  tmp_dir:
    type: ['null', string]
    default: /scratch/<username>/...
    doc: Folder to retain intermediate VCFs after runtime
    inputBinding:
      prefix: --tmp-dir

  input_vcf:
    type:
    - string
    - File
    doc: Path to input file in VCF format
    inputBinding:
      prefix: --input-vcf

  vep_forks:
    type:
    - 'null'
    - int
    default: 4
    doc: Number of forked processes to use when running VEP
    inputBinding:
      prefix: --vep-forks

  vcf_tumor_id:
    type: ['null', string]
    default: TUMOR
    doc: Tumor sample ID used in VCF's genotype columns
    inputBinding:
      prefix: --vcf-tumor-id

  tumor_id:
    type: ['null', string]
    default: TUMOR
    doc: Tumor_Sample_Barcode to report in the MAF
    inputBinding:
      prefix: --tumor-id

  filter_vcf:
    type:
    - 'null'
    - string
    - File
    doc: The non-TCGA VCF from exac.broadinstitute.org
    inputBinding:
      prefix: --filter-vcf

    secondaryFiles:
    - .tbi
  retain_info:
    type: ['null', string]
    doc: Comma-delimited names of INFO fields to retain as extra columns in MAF
    inputBinding:
      prefix: --retain-info


outputs:
  output:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.output_maf)
            return inputs.output_maf;
          return null;
        }
