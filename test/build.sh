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
mv $parentDir/test/run-example.sh .
mv $parentDir/test/run-example-sv.sh .
mv $parentDir/test/run-pipeline.sh .
source $parentDir/setup/config/test-settings.sh
rm -f $parentDir/setup/config/test-settings.sh

export PATH=$ROSLIN_CORE_BIN_PATH:$PATH

function store_test_logs {
    cd $ROSLIN_PIPELINE_ROOT/outputs
    cd $(ls -d */|head -n 1)
    cd $(ls -d */|head -n 1)
    printf "Storing project-workflow.cwl logs..."
    cp stderr.log $parentDir/$TestDir/test_stderr.txt
    cp stdout.log $parentDir/$TestDir/test_stdout.txt
}

function store_test_logs_sv {
    cd $ROSLIN_PIPELINE_ROOT/outputs
    cd $(ls -d */ | tail -n 1)
    cd $(ls -d */ | head -n 1)
    printf "Storing project-workflow-sv.cwl logs..."
    cp stderr.log $parentDir/$TestDir/test_stderr_sv.txt
    cp stdout.log $parentDir/$TestDir/test_stdout_sv.txt
}

function store_test_logs_run_pipeline {
    cd $ROSLIN_PIPELINE_ROOT/outputs 
    cd $(ls -d */ | tail -n 1)
    cd $(ls -d */ | head -n 1)
    printf "Storing run_pipeline.py logs..."
#    cp stderr.log $parentDir/$TestDir/test_stderr_run_pipeline.txt
    cp stdout.log $parentDir/$TestDir/test_stdout_run_pipeline.txt
}

chmod +x run-example.sh
chmod +x run-example-sv.sh
chmod +x run-pipeline.sh

pipelineLeaderId=$(./run-example.sh | egrep -o -m 1 '[0-9]{8}')
pipelineLeaderIdSV=$(./run-example-sv.sh | egrep -o -m 1 '[0-9]{8}')
#pipelineLeaderIdRP=$(./run-pipeline.sh | egrep -o -m 1 '[0-9]{8}')
printf "project-workflow.cwl pipelineLeaderId: $pipelineLeaderId\nproject-workflow-sv.cwl pipelineLeaderIdSV: $pipelineLeaderIdSV\n" #Pipeline 2.5.0 ID: $pipelineLeaderIdRP\n"
runningBool=1

while [ $runningBool != 0 ]
do
    leaderStatus=$(bjobs $pipelineLeaderId | awk '{print $3}' | tail -1)
    leaderStatusSV=$(bjobs $pipelineLeaderIdSV | awk '{print $3}' | tail -1)
#    leaderStatusRP=$(bjobs $pipelineLeaderIdRP | awk '{print $3}' | tail -1)

    printf "Regular: $leaderStatus; SV: $leaderStatusSV;\n" #RP: $leaderStatusRP\n"

    if [ "$leaderStatus" == "DONE" ] && [ "$leaderStatusSV" == "DONE" ] ] #&& [ "$leaderStatusRP" == "DONE" ]
    then
        printf "All Jobs Finished Successfully\n"
        store_test_logs
        store_test_logs_sv
#        store_test_logs_run_pipeline
        runningBool=0
    fi

    if [ "$leaderStatus" == "EXIT" ] || [ "$leaderStatusSV" == "EXIT" ] ]# || [ "$leaderStatusRP" == "EXIT" ]
    then
        printf "One or more of the jobs have failed\n"
        if [ "$leaderStatusRP" != "EXIT" ]
        then
            `bkill $leaderStatusRP`
        fi
        runningBool=0
        store_test_logs
        store_test_logs_sv
    #    store_test_logs_run_pipeline
        exit 1
    fi
    sleep 1m
done
