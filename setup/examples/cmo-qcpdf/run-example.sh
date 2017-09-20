#!/bin/bash

roslin-runner.sh \
    -w cmo-qcpdf/0.5.0/cmo-qcpdf.cwl \
    -i inputs.yaml \
    -b lsf
