#!/bin/bash

# modify inputs.yaml to have an user-specific, collision safe working directory
uuid=`python -c 'import uuid; print str(uuid.uuid1())'`
tmpdir="$HOME/tmp/$uuid"
eval "echo \"$(cat debug-inputs.yaml.template)\"" > debug-inputs.yaml

prism-runner.sh \
    -w module-2a.cwl \
    -i inputs.yaml \
    -b lsf
