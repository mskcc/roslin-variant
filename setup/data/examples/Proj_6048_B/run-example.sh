#!/bin/bash

prism_request_to_yaml.py \
	-m Proj_6048_B_sample_mapping.txt \
	-p Proj_6048_B_sample_pairing.txt \
	-g Proj_6048_B_sample_grouping.txt \
	-r Proj_6048_B_request.txt \
	-o . \
	-f inputs.yaml

nohup prism-runner.sh \
	-w project-workflow.cwl \
	-i inputs.yaml \
	-b lsf &

# prism_submit.py \
#     --id Proj_6048_B \
#     --path . \
#     --workflow project-workflow.cwl
