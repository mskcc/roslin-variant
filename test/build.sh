#!/bin/bash
# Set estimated walltime <60 mins and use the barely used internet nodes, to reduce job PEND times
cd ..
git submodule update --force
testParentDir=$(pwd)
source build-pipeline.sh -t -b $BUILD_NUMBER

TestDir=test_output/$BUILD_NUMBER
# Run test
printf "\n----------Running Test----------\n"

cd $ROSLIN_PIPELINE_WORKSPACE_PATH/$USER/examples
source $parentDir/setup/config/test-settings.sh
rm -f $parentDir/setup/config/test-settings.sh

export TMPDIR_TEST=$TMPDIR

export PATH=$ROSLIN_CORE_BIN_PATH:$PATH
chmod +x */run-example.sh
pytest -n 5 roslin_workflows_test.py