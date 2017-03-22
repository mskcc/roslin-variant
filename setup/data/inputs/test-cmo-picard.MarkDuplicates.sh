#!/bin/bash

prism-runner.sh \
    -w cmo-picard.MarkDuplicates/1.96/cmo-picard.MarkDuplicates.cwl \
    -i inputs-cmo-picard.MarkDuplicates.yaml \
    -d -b lsf 2>&1 | tee ./outputs/stdout.log
