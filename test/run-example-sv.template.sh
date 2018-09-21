#!/bin/bash

pipeline_name_version="{{ pipeline_name }}/{{ pipeline_version }}"

roslin_request_to_yaml.py \
    --pipeline ${pipeline_name_version} \
    -m Proj_DEV_0002_sample_mapping.txt \
    -p Proj_DEV_0002_sample_pairing.txt \
    -g Proj_DEV_0002_sample_grouping.txt \
    -r Proj_DEV_0002_request.txt \
    -o . \
    -f inputs.yaml \
    {{ run_args }}

roslin_submit.py \
    --id Proj_DEV_0002 \
    --path . \
    --workflow project-workflow-sv.cwl \
    --single-node \
    --pipeline ${pipeline_name_version}
