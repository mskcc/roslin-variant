#!/bin/bash

pipeline_name_version="variant/1.0.0"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w cmo-picard.MarkDuplicates/1.96/cmo-picard.MarkDuplicates.cwl \
    -i inputs.yaml \
    -b lsf
