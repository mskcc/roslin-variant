#!/bin/bash

prism_request_to_yaml.py \
	-m Proj_UTest02_s16_sample_mapping.txt \
	-p Proj_UTest02_s16_sample_pairing.txt \
	-g Proj_UTest02_s16_sample_grouping.txt \
	-r Proj_UTest02_s16_request.txt \
	-o . \
	-f inputs.yaml

nohup prism-runner.sh \
	-w project-workflow.cwl \
	-i inputs.yaml \
	-b lsf &

# roslin_submit.py \
#     --id Proj_UTest02_s16 \
#     --path . \
#     --workflow project-workflow.cwl
