#!/bin/bash

pipeline_name_version="variant/1.0.0"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w remove-variants/0.1.1/remove-variants.cwl \
    -i inputs.yaml \
    -b lsf
