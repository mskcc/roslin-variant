#!/bin/bash
unset TOIL_LSF_ARGS
cd ..
source build-pipeline.sh -t -b $1
# Run test
printf "\n----------Running Test----------\n"
cd $ROSLIN_EXAMPLE_PATH
source $parentDir/core/config/settings.sh
# Load virtualenv to use pytest
source $parentDir/setup/config/settings.sh
source $parentDir/setup/config/test-settings.sh
# cleanup settings files
rm -f $parentDir/core/config/settings.sh
rm -f $parentDir/setup/config/settings.sh
rm -f $parentDir/setup/config/test-settings.sh
pip install pytest-xdist
export TMPDIR_TEST=$TMPDIR
export LOG_TEST=$2
export PATH=$ROSLIN_CORE_BIN_PATH:$PATH
pytest -n 8 $ROSLIN_CORE_BIN_PATH/roslin_workflows_test.py
