#!/bin/bash

pipeline_name_version="variant/1.0.1"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w cmo-bwa-mem/0.7.5a/cmo-bwa-mem.cwl \
    -i inputs.yaml \
    -b lsf
