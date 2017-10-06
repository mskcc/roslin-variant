#!/bin/bash

pipeline_name_version="variant/1.0.1"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w cmo-gatk.CombineVariants/3.3-0/cmo-gatk.CombineVariants.cwl \
    -i inputs.yaml \
    -b lsf
