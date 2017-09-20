#!/bin/bash

roslin-runner.sh \
    -w cmo-split-reads/1.0.0/cmo-split-reads.cwl \
    -i inputs.yaml \
    -b lsf
