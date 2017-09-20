#!/bin/bash

roslin-runner.sh \
    -w cmo-gatk.FindCoveredIntervals/3.3-0/cmo-gatk.FindCoveredIntervals.cwl \
    -i inputs.yaml \
    -b lsf
