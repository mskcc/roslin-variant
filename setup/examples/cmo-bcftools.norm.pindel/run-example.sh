#!/bin/bash

roslin-runner.sh \
    -w cmo-bcftools.norm/1.3.1/cmo-bcftools.norm.cwl \
    -i inputs.yaml \
    -b lsf
