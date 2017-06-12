#!/bin/bash

prism-runner.sh \
    -w module-4.vcf.cwl \
    -i inputs.yaml \
    -b lsf
