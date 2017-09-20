#!/bin/bash

roslin-runner.sh \
    -w flatten-array/1.0.0/flatten-array-fastq.cwl \
    -i inputs.yaml \
    -b lsf
