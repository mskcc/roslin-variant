#!/bin/bash

roslin-runner.sh \
    -w ngs-filters/1.1.4/ngs-filters.cwl \
    -i inputs.yaml \
    -b lsf
