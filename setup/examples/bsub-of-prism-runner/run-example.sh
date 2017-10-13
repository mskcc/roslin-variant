#!/bin/bash

pipeline_name_version="variant/1.3.1"

bsub -q test -K -cwd . \
    -eo ./stderr.txt \
    -oo ./stdout.txt \
    "roslin-runner.sh -v ${pipeline_name_version} -w samtools/1.3.1/samtools-sam2bam.cwl -i ./inputs.yaml -b lsf"
