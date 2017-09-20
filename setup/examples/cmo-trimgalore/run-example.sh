#!/bin/bash

roslin-runner.sh \
    -w cmo-trimgalore/0.2.5.mod/cmo-trimgalore.cwl \
    -i inputs.yaml \
    -b lsf
