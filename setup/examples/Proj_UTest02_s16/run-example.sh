#!/bin/bash

pipeline_name_version="variant/1.0.1"

roslin_request_to_yaml.py \
    -m Proj_UTest02_s16_sample_mapping.txt \
    -p Proj_UTest02_s16_sample_pairing.txt \
    -g Proj_UTest02_s16_sample_grouping.txt \
    -r Proj_UTest02_s16_request.txt \
    -o . \
    -f inputs.yaml

# nohup roslin-runner.sh \
# 	-v ${pipeline_name_version} \
# 	-w project-workflow.cwl \
# 	-i inputs.yaml \
# 	-b lsf &

roslin_submit.py \
    --id Proj_UTest02_s16 \
    --path . \
    --workflow project-workflow.cwl \
    --pipeline ${pipeline_name_version}
