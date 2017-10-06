#!/bin/bash

pipeline_name_version="variant/1.0.1"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w cmo-fillout/1.2.1/cmo-fillout.cwl \
    -i inputs.yaml \
    -b lsf
