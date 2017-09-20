#!/bin/bash

pipeline_name_version="variant/1.0.0"

roslin_request_to_yaml.py \
	-m Proj_6048_B_sample_mapping.txt \
	-p Proj_6048_B_sample_pairing.txt \
	-g Proj_6048_B_sample_grouping.txt \
	-r Proj_6048_B_request.txt \
	-o . \
	-f inputs.yaml

# nohup roslin-runner.sh \
# 	-v ${pipeline_name_version} \
# 	-w project-workflow.cwl \
# 	-i inputs.yaml \
# 	-b lsf &

roslin_submit.py \
    --id Proj_6048_B \
    --path . \
    --workflow project-workflow.cwl \
	--pipeline ${pipeline_name_version}
