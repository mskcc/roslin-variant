#!/bin/bash

prism-runner.sh \
    -w cmo-trimgalore/0.2.5.mod/cmo-trimgalore.cwl \
    -i inputs-cmo-trimgalore.yaml \
    -b lsf
