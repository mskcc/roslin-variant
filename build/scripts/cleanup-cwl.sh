#!/bin/bash

# load build-related settings
source ./settings-build.sh

# load utils
source ./tools-utils.sh

# delete cwl wrappers created
find ${CWL_WRAPPER_DIRECTORY}/ -name '*.cwl' ! -name '*.original.cwl' -type f

# delete error files
rm -rf error.*.txt
