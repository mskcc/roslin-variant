#!/bin/bash

# nohup roslin-runner.sh \
# 	-w project-workflow.cwl \
# 	-i inputs.yaml \
# 	-b lsf &

roslin_submit.py \
   --id Proj_DMPVAL_01_5 \
   --path . \
   --workflow project-workflow.cwl
