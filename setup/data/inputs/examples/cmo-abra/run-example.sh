#!/bin/bash

# modify inputs.yaml.template to have an user-specific, collision safe working directory
uuid=`python -c 'import uuid; print str(uuid.uuid1())'`
tmpdir="$HOME/tmp/prism-$uuid"
mkdir -p "$HOME/tmp"
eval "echo \"$(cat inputs.yaml.template)\"" > inputs.yaml

prism-runner.sh \
    -w cmo-abra/0.92/cmo-abra.cwl \
    -i inputs.yaml \
    -b lsf
