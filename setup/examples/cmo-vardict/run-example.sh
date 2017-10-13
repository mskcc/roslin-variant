#!/bin/bash

pipeline_name_version="variant/1.3.1"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w cmo-vardict/1.4.6/cmo-vardict.cwl \
    -i inputs.yaml \
    -b lsf
