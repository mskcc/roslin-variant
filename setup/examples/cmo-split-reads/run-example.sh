#!/bin/bash

pipeline_name_version="variant/1.0.1"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w cmo-split-reads/1.0.0/cmo-split-reads.cwl \
    -i inputs.yaml \
    -b lsf
