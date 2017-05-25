#!/bin/bash

prism-runner.sh \
    -w cmo-fillout/1.1.9/cmo-fillout.cwl \
    -i inputs.yaml \
    -b lsf
