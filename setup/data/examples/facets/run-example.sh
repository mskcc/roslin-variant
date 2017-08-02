#!/bin/bash

prism-runner.sh \
    -w facets.cwl \
    -i inputs.yaml \
    -b lsf -d
