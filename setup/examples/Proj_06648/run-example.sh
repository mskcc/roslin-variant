#!/bin/bash

roslin_request_to_yaml.py \
	-m Proj_06648_sample_mapping.txt \
	-p Proj_06648_sample_pairing.txt \
	-g Proj_06648_sample_grouping.txt \
	-r Proj_06648_request.txt \
	-o . \
	-f inputs.yaml

nohup roslin-runner.sh \
	-w project-workflow.cwl \
	-i inputs.yaml \
	-b lsf &

# roslin_submit.py \
#     --id Proj_06648 \
#     --path . \
#     --workflow project-workflow.cwl
