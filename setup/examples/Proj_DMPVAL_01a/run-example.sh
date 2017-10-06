#!/bin/bash

pipeline_name_version="variant/1.0.1"

# nohup roslin-runner.sh \
#     -v ${pipeline_name_version} \
#     -w project-workflow.cwl \
#     -i inputs.yaml \
#     -b lsf &

roslin_submit.py \
    --id Proj_DMPVAL_01a \
    --path . \
    --workflow project-workflow.cwl \
    --pipeline ${pipeline_name_version}
