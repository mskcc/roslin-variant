#!/bin/bash

prism-runner.sh \
    -w flatten-array/1.0.0/flatten-array.cwl \
    -i inputs.yaml \
    -b lsf
