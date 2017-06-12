#!/bin/bash

prism-runner.sh \
    -w basic-filtering.somaticIndelDetector/0.1.6/basic-filtering.somaticIndelDetector.cwl \
    -i inputs.yaml \
    -b lsf
