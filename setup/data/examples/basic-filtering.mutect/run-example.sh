#!/bin/bash

prism-runner.sh \
    -w basic-filtering.mutect/0.1.6/basic-filtering.mutect.cwl \
    -i inputs.yaml \
    -b lsf
