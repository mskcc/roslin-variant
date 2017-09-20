#!/bin/bash

roslin-runner.sh \
    -w basic-filtering.vardict/0.1.7/basic-filtering.vardict.cwl \
    -i inputs.yaml \
    -b lsf
