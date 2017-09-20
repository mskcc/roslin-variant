#!/bin/bash

bsub -q test -K -cwd . \
    -eo ./stderr.txt \
    -oo ./stdout.txt \
    "roslin-runner.sh -w samtools/1.3.1/samtools-sam2bam.cwl -i ./inputs.yaml -b lsf"
