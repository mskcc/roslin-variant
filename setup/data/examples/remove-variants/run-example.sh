#!/bin/bash

prism-runner.sh \
    -w remove-variants/0.1.1/remove-variants.cwl \
    -i inputs.yaml \
    -b lsf
