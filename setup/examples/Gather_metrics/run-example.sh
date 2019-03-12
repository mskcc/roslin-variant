#!/bin/bash

pipeline_name=${ROSLIN_PIPELINE_NAME}
pipeline_version=${ROSLIN_PIPELINE_VERSION}

roslin_request_to_yaml.py \
    --pipeline ${pipeline_name}/${pipeline_version} \
    -m Gather_metrics_sample_mapping.txt \
    -p Gather_metrics_sample_pairing.txt \
    -g Gather_metrics_sample_grouping.txt \
    -r Gather_metrics_request.txt \
    -o . \
    -f inputs.yaml

roslin_submit.py \
    --name ${pipeline_name} \
    --version ${pipeline_version} \
    --id Gather_metrics \
    --inputs inputs.yaml \
    --results ${ROSLIN_PIPELINE_OUTPUT_PATH} \
    --path . \
    --workflow GatherMetrics \
    --batch-system ${ROSLIN_TEST_BATCHSYSTEM} \
    --cwl-batch-system ${ROSLIN_TEST_CWL_BATCHSYSTEM} \
    --foreground-mode \
    --test-mode ${ROSLIN_TEST_RUN_ARGS} \
    --use_alignment_meta alignment-input-meta.json
