#!/bin/bash

pipeline_name_version="variant/1.0.0"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w cmo-pindel/0.2.5a7/cmo-pindel.cwl \
    -i inputs.yaml \
    -b lsf

# cmo_pindel \
#     --version \
#     0.2.5a7 \
#     --bam \
#     '../data/from-module-2/P2_ADDRG_MD.abra.fmi.printreads.bam ../data/from-module-2/P1_ADDRG_MD.abra.fmi.printreads.bam' \
#     --fasta \
#     GRCh37 \
#     --output-prefix \
#     Tumor \
#     --sample_names \
#     'Normal Tumor' \
#     --vcf \
#     Tumor.pindel.vcf
