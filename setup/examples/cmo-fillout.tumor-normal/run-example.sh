#!/bin/bash

prism-runner.sh \
    -w cmo-fillout/1.2.1/cmo-fillout.cwl \
    -i inputs.yaml \
    -b lsf
