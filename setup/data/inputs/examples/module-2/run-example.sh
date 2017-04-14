#!/bin/bash

# modify inputs.yaml.template to have an user-specific, collision safe working directory
uuid=`python -c 'import uuid; print str(uuid.uuid1())'`
tmpdir="$HOME/tmp/$uuid"
eval "echo \"$(cat inputs.yaml.template)\"" > inputs.yaml

prism-runner.sh \
    -w module-2.cwl \
    -i inputs.yaml \
    -b singleMachine
