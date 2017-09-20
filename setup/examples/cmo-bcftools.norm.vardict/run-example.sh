#!/bin/bash

pipeline_name_version="variant/1.0.0"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w cmo-bcftools.norm/1.3.1/cmo-bcftools.norm.cwl \
    -i inputs.yaml \
    -b lsf
