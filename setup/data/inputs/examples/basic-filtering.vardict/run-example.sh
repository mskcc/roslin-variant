#!/bin/bash

prism-runner.sh \
    -w basic-filtering.vardict/0.1.6/basic-filtering.vardict.cwl \
    -i inputs.yaml \
    -b lsf
