#!/bin/bash

# Set estimated walltime <60 mins and use the barely used internet nodes, to reduce job PEND times
cd ..
source build-pipeline.sh -t -b $1
# Run test
printf "\n----------Running Test----------\n"
cd $ROSLIN_EXAMPLE_PATH
source $parentDir/setup/config/test-settings.sh
rm -f $parentDir/setup/config/test-settings.sh
export TMPDIR_TEST=$TMPDIR
export LOG_TEST=$2
export PATH=$ROSLIN_CORE_BIN_PATH:$PATH
pytest -n 8 $ROSLIN_CORE_BIN_PATH/roslin_workflows_test.py
