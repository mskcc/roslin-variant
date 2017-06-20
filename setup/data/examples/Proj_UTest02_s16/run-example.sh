#!/bin/bash

request_to_yaml.py \
	-m Proj_UTest02_s16_sample_mapping.txt \
	-p Proj_UTest02_s16_sample_pairing.txt \
	-g Proj_UTest02_s16_sample_grouping.txt \
	-o . \
	-f inputs.yaml

prism-runner.sh \
	-v test2 \
	-w project-workflow.cwl \
	-i inputs.yaml \
	-b lsf

# prism_submit.py \
#     --id Proj_UTest02_s16 \
#     --path . \
#     --workflow project-workflow.cwl
