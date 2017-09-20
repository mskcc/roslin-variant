#!/bin/bash

roslin_request_to_yaml.py \
    -m Proj_DMPVAL_01_sample_mapping.txt \
    -p Proj_DMPVAL_01_sample_pairing.txt \
    -g Proj_DMPVAL_01_sample_grouping.txt \
    -r Proj_DMPVAL_01_request.txt \
    -o . \
    -f inputs.yaml

# nohup roslin-runner.sh \
# 	-w project-workflow.cwl \
# 	-i inputs.yaml \
# 	-b lsf &

# roslin_submit.py \
#    --id Proj_DMPVAL_01 \
#    --path . \
#    --workflow project-workflow.cwl
