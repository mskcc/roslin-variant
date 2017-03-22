#!/bin/bash

prism-runner.sh \
    -w cmo-picard.AddOrReplaceReadGroups/1.96/cmo-picard.AddOrReplaceReadGroups.cwl \
    -i inputs-cmo-picard.AddOrReplaceReadGroups.yaml \
    -d -b lsf 2>&1 | tee ./outputs/stdout.log
