#!/bin/bash

prism-runner.sh \
    -w facets/1.5.4/facets.cwl \
    -i inputs.yaml \
    -b lsf -d