#!/bin/bash

prism-runner.sh \
    -w module-1.scatter.cwl \
    -i inputs.yaml \
    -b lsf
