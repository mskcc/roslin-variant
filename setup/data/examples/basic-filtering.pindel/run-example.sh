#!/bin/bash

prism-runner.sh \
    -w basic-filtering.pindel/0.1.7/basic-filtering.pindel.cwl \
    -i inputs.yaml \
    -b lsf
