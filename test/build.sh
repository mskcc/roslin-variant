#!/bin/bash
# Set estimated walltime <60 mins and use the barely used internet nodes, to reduce job PEND times
cd ..
git submodule update --force
testParentDir=$(pwd)
source build-pipeline.sh -t -b $BUILD_NUMBER

TestDir=test_output/$BUILD_NUMBER
# Run test
printf "\n----------Running Test----------\n"

cd $ROSLIN_PIPELINE_ROOT/workspace/jenkins/examples/Proj_DEV_0003
mv $parentDir/test/run-pipeline.sh .
source $parentDir/setup/config/test-settings.sh
rm -f $parentDir/setup/config/test-settings.sh

export PATH=$ROSLIN_CORE_BIN_PATH:$PATH

function store_test_logs_run_pipeline {
    cd $ROSLIN_PIPELINE_ROOT/outputs 
    cd $(ls -d */ | tail -n 1)
    cd $(ls -d */ | head -n 1)
    cp stderr.log $parentDir/$TestDir/test_stderr_run_pipeline.txt
    cp stdout.log $parentDir/$TestDir/test_stdout_run_pipeline.txt
}

chmod +x run-pipeline.sh

pipelineLeaderIdRP=$(./run-pipeline.sh | egrep -o -m 1 '[0-9]{8}')

printf "Run Pipeline: $pipelineLeaderIdRP\n"
runningBool=1
jobTrackBoolRP=1

while [ $runningBool != 0 ]
do
    leaderStatusRP=$(bjobs $pipelineLeaderIdRP | awk '{print $3}' | tail -1)

    printf "RP: $leaderStatusRP\n"

    if [ "$leaderStatusRP" == "DONE" ]
    then
        printf "All Jobs Finished Successfully\n"
        store_test_logs_run_pipeline
        runningBool=0
    fi

    if [ $jobTrackBoolRP != 0 ]
    then
        if [ "$leaderStatusRP" == "DONE" ] 
        then
            printf "Job RP Finished Successfully\n"
            store_test_logs_run_pipeline
            jobTrackBoolRP=0
        elif [ "$leaderStatusRP" == "EXIT" ]
        then
            printf "Job RP Failed\n"
            store_test_logs_run_pipeline
            jobTrackBoolRP=0
        fi
    fi

    if [ $jobTrackBoolRP == 0 ]
    then
        store_test_logs_run_pipeline
        runningBool=0
        if [ "$leaderStatusRP" == "EXIT" ]
        then
            printf "One or more jobs failed; check logs\n"
            exit 1
        fi
    fi
    sleep 2m
done
