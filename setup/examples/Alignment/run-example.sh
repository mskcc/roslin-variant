#!/bin/bash

pipeline_name=${ROSLIN_PIPELINE_NAME}
pipeline_version=${ROSLIN_PIPELINE_VERSION}

roslin_request_to_yaml.py \
    --pipeline ${pipeline_name}/${pipeline_version} \
    -m Alignment_sample_mapping.txt \
    -p Alignment_sample_pairing.txt \
    -g Alignment_sample_grouping.txt \
    -r Alignment_request.txt \
    -o . \
    -f inputs.yaml

roslin_submit.py \
    --name ${pipeline_name} \
    --version ${pipeline_version} \
    --id Alignment \
    --inputs inputs.yaml \
    --path . \
    --workflow Alignment \
    --batch-system singleMachine \
    --foreground-mode
