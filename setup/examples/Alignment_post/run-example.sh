#!/bin/bash

pipeline_name=${ROSLIN_PIPELINE_NAME}
pipeline_version=${ROSLIN_PIPELINE_VERSION}

roslin_request_to_yaml.py \
    --pipeline ${pipeline_name}/${pipeline_version} \
    -m Alignment_post_sample_mapping.txt \
    -p Alignment_post_sample_pairing.txt \
    -g Alignment_post_sample_grouping.txt \
    -r Alignment_post_request.txt \
    -o . \
    -f inputs.yaml

roslin_submit.py \
    --name ${pipeline_name} \
    --version ${pipeline_version} \
    --id Alignment_post \
    --inputs inputs.yaml \
    --path . \
    --workflow AlignmentPost \
    --batch-system singleMachine \
    --foreground-mode \
    --use_alignment_meta alignment-input-meta.json
