#!/bin/bash

pipeline_name_version="variant/1.0.0"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w basic-filtering.pindel/0.1.7/basic-filtering.pindel.cwl \
    -i inputs.yaml \
    -b lsf
