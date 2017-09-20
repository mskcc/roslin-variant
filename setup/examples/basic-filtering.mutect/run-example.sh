#!/bin/bash

roslin-runner.sh \
    -w basic-filtering.mutect/0.1.7/basic-filtering.mutect.cwl \
    -i inputs.yaml \
    -b lsf
