#!/bin/bash

prism-runner.sh \
    -w replace-allele-counts/0.1.0/replace-allele-counts.cwl \
    -i inputs.yaml \
    -b lsf
