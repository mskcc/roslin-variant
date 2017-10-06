#!/bin/bash

pipeline_name_version="variant/1.0.1"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w cmo-abra/2.08/cmo-abra.cwl \
    -i inputs.yaml \
    -b lsf
