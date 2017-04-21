#!/bin/bash

prism-runner.sh \
    -w cmo-mutect/1.1.4/cmo-mutect.cwl \
    -i inputs.yaml \
    -b lsf


# cmo_mutect \
#     --cosmic /ifs/work/socci/Pipelines/CBE/variants_pipeline/data/b37/CosmicCodingMuts_v67_b37_20131024__NDS.vcf \
#     --dbsnp /ifs/work/charris/temp_depot/dbsnp_138.b37.excluding_sites_after_129.vcf \
#     --downsampling_type NONE \
#     --enable_extended_output \
#     --input_file:normal ../data/from-module-2/P2_ADDRG_MD.abra.fmi.printreads.bam \
#     --input_file:tumor ../data/from-module-2/P1_ADDRG_MD.abra.fmi.printreads.bam \
#     --java_args '-Xmx48g -Xms256m -XX:-UseGCOverheadLimit' \
#     --reference_sequence GRCh37
