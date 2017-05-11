#!/bin/bash

prism-runner.sh \
    -w cmo-vcf2maf/1.6.12/cmo-vcf2maf.cwl \
    -i inputs.yaml \
    -b lsf
