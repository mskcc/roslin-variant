#!/bin/bash

roslin-runner.sh \
    -w cmo-vardict/1.4.6/cmo-vardict.cwl \
    -i inputs.yaml \
    -b lsf
