#!/bin/bash

# nohup prism-runner.sh \
# 	-w project-workflow.cwl \
# 	-i inputs.yaml \
# 	-b lsf &

roslin_submit.py \
   --id Proj_DMPVAL_01a \
   --path . \
   --workflow project-workflow.cwl
