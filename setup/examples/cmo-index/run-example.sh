#!/bin/bash

pipeline_name_version="variant/1.0.1"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w cmo-index/1.0.0/cmo-index.cwl \
    -i inputs.yaml \
    -b lsf
