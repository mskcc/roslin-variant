#!/bin/bash

prism-runner.sh \
    -w cmo-gatk.SomaticIndelDetector/2.3-9/cmo-gatk.SomaticIndelDetector.cwl \
    -i inputs.yaml \
    -b lsf
