#!/bin/bash

pipeline_name_version="variant/1.0.0"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w cmo-trimgalore/0.2.5.mod/cmo-trimgalore.cwl \
    -i inputs.yaml \
    -b lsf
