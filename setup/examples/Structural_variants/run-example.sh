#!/bin/bash

pipeline_name=${ROSLIN_PIPELINE_NAME}
pipeline_version=${ROSLIN_PIPELINE_VERSION}

roslin_request_to_yaml.py \
    --pipeline ${pipeline_name}/${pipeline_version} \
    -m Structural_variants_sample_mapping.txt \
    -p Structural_variants_sample_pairing.txt \
    -g Structural_variants_sample_grouping.txt \
    -r Structural_variants_request.txt \
    -o . \
    -f inputs.yaml

roslin_submit.py \
    --name ${pipeline_name} \
    --version ${pipeline_version} \
    --id Structural_variants \
    --inputs inputs.yaml \
    --path . \
    --workflow StructuralVariants \
    --batch-system singleMachine \
    --foreground-mode \
    --test-mode \
    --use_alignment_meta alignment-input-meta.json
