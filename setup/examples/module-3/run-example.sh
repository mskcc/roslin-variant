#!/bin/bash

pipeline_name_version="variant/1.0.1"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w module-3.cwl \
    -i inputs.yaml \
    -b lsf
