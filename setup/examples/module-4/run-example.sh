#!/bin/bash

pipeline_name_version="variant/1.0.0"
workflow="module-4.cwl"

if [ "$1" = "-s" ]
then
    roslin_submit.py \
        --id Proj_DEV_${USER} \
        --path . \
        --workflow ${workflow}
else
    roslin-runner.sh \
        -v ${pipeline_name_version} \
        -w ${workflow} \
        -i inputs.yaml \
        -b lsf
fi
