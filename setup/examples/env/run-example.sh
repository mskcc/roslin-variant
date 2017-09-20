#!/bin/bash

roslin-runner.sh \
    -v test \
    -w env.cwl \
    -i input.yaml \
    -b lsf
