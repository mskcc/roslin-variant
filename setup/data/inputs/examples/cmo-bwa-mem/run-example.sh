#!/bin/bash

prism-runner.sh \
    -w cmo-bwa-mem/0.7.5a/cmo-bwa-mem.cwl \
    -i inputs.yaml \
    -b lsf
