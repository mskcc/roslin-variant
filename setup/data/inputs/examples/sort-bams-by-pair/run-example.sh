#!/bin/bash

prism-runner.sh \
    -w sort-bams-by-pair/1.0.0/sort-bams-by-pair.cwl \
    -i inputs.yaml \
    -b lsf
