#!/bin/bash

roslin-runner.sh \
    -w samtools/1.3.1/samtools-sam2bam.cwl \
    -i inputs.yaml \
    -b lsf
