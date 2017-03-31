#!/bin/bash

prism-runner.sh \
    -v test \
    -w env.cwl \
    -i input.yaml \
    -b lsf
