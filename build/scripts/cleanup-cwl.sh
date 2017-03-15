#!/bin/bash

# load build-related settings
source ./settings-build.sh

# load utils
source ./tools-utils.sh

# delete singularity images created
find ${CWL_WRAPPER_DIRECTORY}/ -name '*.cwl' -type f -delete
