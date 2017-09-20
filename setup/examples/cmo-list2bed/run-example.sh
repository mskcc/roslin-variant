#!/bin/bash

pipeline_name_version="variant/1.0.0"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w cmo-list2bed/1.0.1/cmo-list2bed.cwl \
    -i inputs.yaml \
    -b lsf
