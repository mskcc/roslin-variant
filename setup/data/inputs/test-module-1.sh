#!/bin/bash

prism-runner.sh \
    -w module-1.cwl \
    -i inputs-module-1.yaml \
    -d -b lsf 2>&1 | tee ./outputs/stdout.log
