#!/bin/bash

roslin-runner.sh \
    -w cmo-gatk.CombineVariants/3.3-0/cmo-gatk.CombineVariants.cwl \
    -i inputs.yaml \
    -b lsf
