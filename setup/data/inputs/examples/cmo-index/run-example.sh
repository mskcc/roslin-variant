#!/bin/bash

prism-runner.sh \
    -w cmo-index/1.0.0/cmo-index.cwl \
    -i inputs.yaml \
    -b lsf
