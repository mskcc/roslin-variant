#!/bin/bash

prism-runner.sh \
    -w module-5.cwl \
    -i inputs.yaml \
    -b lsf \
    -d
