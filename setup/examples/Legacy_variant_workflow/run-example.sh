#!/bin/bash

pipeline_name=${ROSLIN_PIPELINE_NAME}
pipeline_version=${ROSLIN_PIPELINE_VERSION}

roslin_request_to_yaml.py \
    --pipeline ${pipeline_name}/${pipeline_version} \
    --clinical Legacy_variant_workflow_sample_data_clinical.txt \
    -m Legacy_variant_workflow_sample_mapping.txt \
    -p Legacy_variant_workflow_sample_pairing.txt \
    -g Legacy_variant_workflow_sample_grouping.txt \
    -r Legacy_variant_workflow_request.txt \
    -f inputs.yaml

roslin_submit.py \
    --name ${pipeline_name} \
    --version ${pipeline_version} \
    --id Legacy_variant_workflow \
    --inputs inputs.yaml \
    --results ${ROSLIN_PIPELINE_OUTPUT_PATH} \
    --path . \
    --workflow LegacyVariantWorkflow \
    --batch-system ${ROSLIN_TEST_BATCHSYSTEM} \
    --cwl-batch-system ${ROSLIN_TEST_CWL_BATCHSYSTEM} \
    --test-mode ${ROSLIN_TEST_RUN_ARGS} \
    --foreground-mode