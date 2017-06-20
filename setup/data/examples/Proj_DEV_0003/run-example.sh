#!/bin/bash

request_to_yaml.py \
	-m Proj_DEV_0003_sample_mapping.txt \
	-p Proj_DEV_0003_sample_pairing.txt \
	-g Proj_DEV_0003_sample_grouping.txt \
	-o . \
	-f inputs.yaml

prism-runner.sh \
	-v test2 \
	-w project-workflow.cwl \
	-i inputs.yaml \
	-b lsf

# prism_submit.py \
#     --id Proj_DEV_0003 \
#     --path . \
#     --workflow project-workflow.cwl
