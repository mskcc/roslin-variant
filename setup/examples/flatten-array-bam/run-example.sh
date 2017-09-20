#!/bin/bash

roslin-runner.sh \
    -w flatten-array/1.0.0/flatten-array-bam.cwl \
    -i inputs.yaml \
    -b lsf
