#!/bin/bash

pipeline_name_version="variant/1.0.0"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w sort-bams-by-pair/1.0.0/sort-bams-by-pair.cwl \
    -i inputs.yaml \
    -b lsf
