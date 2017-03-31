#!/bin/bash

# fixme: working directory defined in inputs.yaml
# at runtime, abra complains "unable to delete", so we delete before start
rm -rf /ifs/work/chunj/prism-proto/prism/tmp/abra

prism-runner.sh \
    -w cmo-abra/0.92/cmo-abra.cwl \
    -i inputs.yaml \
    -b lsf
