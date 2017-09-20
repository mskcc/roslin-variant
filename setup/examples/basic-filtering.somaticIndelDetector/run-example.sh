#!/bin/bash

roslin-runner.sh \
    -w basic-filtering.somaticIndelDetector/0.1.7/basic-filtering.somaticIndelDetector.cwl \
    -i inputs.yaml \
    -b lsf
