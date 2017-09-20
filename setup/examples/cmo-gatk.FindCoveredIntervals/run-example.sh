#!/bin/bash

pipeline_name_version="variant/1.0.0"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w cmo-gatk.FindCoveredIntervals/3.3-0/cmo-gatk.FindCoveredIntervals.cwl \
    -i inputs.yaml \
    -b lsf
