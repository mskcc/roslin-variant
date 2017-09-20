#!/bin/bash

roslin-runner.sh \
    -w cmo-picard.AddOrReplaceReadGroups/1.96/cmo-picard.AddOrReplaceReadGroups.cwl \
    -i inputs.yaml \
    -b lsf
