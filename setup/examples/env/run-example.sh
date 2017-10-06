#!/bin/bash

pipeline_name_version="variant/1.0.1"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w test/env.cwl \
    -i input.yaml \
    -b lsf
