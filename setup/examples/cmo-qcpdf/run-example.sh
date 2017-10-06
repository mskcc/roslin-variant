#!/bin/bash

pipeline_name_version="variant/1.0.1"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w cmo-qcpdf/0.5.0/cmo-qcpdf.cwl \
    -i inputs.yaml \
    -b lsf
