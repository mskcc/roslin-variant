#!/bin/bash

roslin-runner.sh \
    -w cmo-abra/2.08/cmo-abra.cwl \
    -i inputs.yaml \
    -b lsf
