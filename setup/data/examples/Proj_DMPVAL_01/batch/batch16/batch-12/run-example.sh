#!/bin/bash

# nohup prism-runner.sh \
# 	-w project-workflow.cwl \
# 	-i inputs.yaml \
# 	-b lsf &

prism_submit.py \
   --id Proj_DMPVAL_01_12 \
   --path . \
   --workflow project-workflow.cwl