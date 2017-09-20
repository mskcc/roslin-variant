#!/bin/bash

workflow="module-4.cwl"

if [ "$1" = "-s" ]
then
    roslin_submit.py \
        --id Proj_DEV_${USER} \
        --path . \
        --workflow ${workflow}
else
    roslin-runner.sh \
        -w ${workflow} \
        -i inputs.yaml \
        -b lsf
fi
