#!/bin/bash

prism-runner.sh \
    -w cmo-bwa-mem/0.7.5a/cmo-bwa-mem.cwl \
    -i inputs-cmo-bwa-mem.yaml \
    -d -b lsf 2>&1 | tee ./outputs/stdout.log
