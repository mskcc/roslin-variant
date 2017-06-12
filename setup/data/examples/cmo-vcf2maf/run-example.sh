#!/bin/bash

prism-runner.sh \
    -w cmo-vcf2maf/1.6.12/cmo-vcf2maf.cwl \
    -i inputs.yaml \
    -b lsf


# cmo_vcf2maf --version 1.6.12 \
#     --vep-data /ifs/work/chunj/prism-proto/ifs/depot/resources/vep/v86 \
#     --ncbi-build GRCh37 \
#     --ref-fasta /ifs/work/chunj/prism-proto/ifs/depot/assemblies/H.sapiens/b37/b37.fasta \
#     --output-maf PoolTumor2-T_bc52_combined-variants.vep.maf \
#     --filter-vcf /ifs/work/chunj/prism-proto/ifs/depot/resources/vep/v86/ExAC_nonTCGA.r0.3.1.sites.vep.vcf.gz \
#     --input-vcf /ifs/work/chunj/prism-proto/ifs/prism/inputs/chunj/examples/data/from-module-4/PoolTumor2-T_bc52_combined-variants.vcf \
#     --species homo_sapiens

# cmo_vcf2maf --version 1.6.12 \
#     --output-maf PoolTumor2-T_bc52_combined-variants.vep.maf \
#     --input-vcf PoolTumor2-T_bc52_combined-variants.vcf \
#     --species homo_sapiens
