#!/bin/bash

pipeline_name=${ROSLIN_PIPELINE_NAME}
pipeline_version=${ROSLIN_PIPELINE_VERSION}

roslin_request_to_yaml.py \
    --pipeline ${pipeline_name}/${pipeline_version} \
    -m Conpair_sample_mapping.txt \
    -p Conpair_sample_pairing.txt \
    -g Conpair_sample_grouping.txt \
    -r Conpair_request.txt \
    -o . \
    -f inputs.yaml

roslin_submit.py \
    --name ${pipeline_name} \
    --version ${pipeline_version} \
    --id Conpair \
    --inputs inputs.yaml \
    --path . \
    --workflow Conpair \
    --batch-system ${ROSLIN_TEST_BATCHSYSTEM} \
    --cwl-batch-system ${ROSLIN_TEST_CWL_BATCHSYSTEM} \
    --foreground-mode \
    --test-mode \
    --use_alignment_meta alignment-input-meta.json
