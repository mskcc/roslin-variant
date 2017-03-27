#!/bin/bash

prism-runner.sh \
    -w cmo-picard.MarkDuplicates/1.96/cmo-picard.MarkDuplicates.cwl \
    -i inputs.yaml \
    -b lsf
