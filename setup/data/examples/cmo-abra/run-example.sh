#!/bin/bash

# modify inputs.yaml.template to have an user-specific,
# collision safe working directory for abra
uuid=`python -c 'import uuid; print str(uuid.uuid1())'`

# $tmpdir is the dynamic variable used in the template
# create right under /scratch, otherwise it will fail
tmpdir="/scratch/prism-abra-$uuid"

# populate the template
eval "echo \"$(cat inputs.yaml.template)\"" > inputs.yaml

prism-runner.sh \
    -w cmo-abra/0.92/cmo-abra.cwl \
    -i inputs.yaml \
    -b lsf
