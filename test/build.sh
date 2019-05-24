#!/bin/bash
# Set estimated walltime <60 mins and use the barely used internet nodes, to reduce job PEND times
cd ..
git submodule update --force
testParentDir=$(pwd)
source build-pipeline.sh -t -b $BUILD_NUMBER

TestDir=test_output/$BUILD_NUMBER
# Run test
printf "\n----------Running Test----------\n"

cd $ROSLIN_DEPENDENCY_PATH/examples
source $parentDir/setup/config/test-settings.sh
rm -f $parentDir/setup/config/test-settings.sh

export TMPDIR_TEST=$TMPDIR
export LOG_TEST=$parentDir/$TestDir/

export PATH=$ROSLIN_CORE_BIN_PATH:$PATH
pytest -n 5 $ROSLIN_CORE_BIN_PATH/roslin_workflows_test.py