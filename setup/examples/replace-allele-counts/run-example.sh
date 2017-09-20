#!/bin/bash

pipeline_name_version="variant/1.0.0"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w replace-allele-counts/0.1.1/replace-allele-counts.cwl \
    -i inputs.yaml \
    -b lsf
