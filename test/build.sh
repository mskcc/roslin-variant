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
source $parentDir/setup/config/test-settings.sh
rm -f $parentDir/setup/config/test-settings.sh

export PATH=$ROSLIN_CORE_BIN_PATH:$PATH

function store_test_logs {
    cd $ROSLIN_PIPELINE_ROOT/outputs
    cd $(ls -d */|head -n 1)
    cd $(ls -d */|head -n 1)
    cp stderr.log $parentDir/$TestDir/test_stderr.txt
    cp stdout.log $parentDir/$TestDir/test_stdout.txt
}

function store_test_logs_sv {
    cd $ROSLIN_PIPELINE_ROOT/outputs
    cd $(ls -d */ | tail -n 1)
    cd $(ls -d */ | head -n 1)
    cp stderr.log $parentDir/$TestDir/test_stderr_sv.txt
    cp stdout.log $parentDir/$TestDir/test_stdout_sv.txt
}

chmod +x run-example.sh
chmod +x run-example-sv.sh
pipelineLeaderId=$(./run-example.sh | egrep -o -m 1 '[0-9]{8}')
pipelineLeaderIdSV=$(./run-example-sv.sh | egrep -o -m 1 '[0-9]{8}')
printf "project-workflow.cwl pipelineLeaderId: $pipelineLeaderId\nproject-workflow-sv.cwl pipelineLeaderIdSV: $pipelineLeaderIdSV\n"
runningBool=1
jobTrackBool=1
jobTrackBoolSV=1

while [ $runningBool != 0 ]
do
    leaderStatus=$(bjobs $pipelineLeaderId | awk '{print $3}' | tail -1)
    leaderStatusSV=$(bjobs $pipelineLeaderIdSV | awk '{print $3}' | tail -1)

    printf "Regular: $leaderStatus; SV: $leaderStatusSV\n"

    if [ "$leaderStatus" == "DONE" ] && [ "$leaderStatusSV" == "DONE" ]
    then
        printf "Both Jobs Finished Successfully\n"
        store_test_logs
        store_test_logs_sv
        runningBool=0
    fi

    if [ $jobTrackBool != 0 ]
    then
        if [ "$leaderStatus" == "DONE" ]
        then
            printf "Job Finished Successfully\n"
            store_test_logs
            jobTrackBool=0
        elif [ "$leaderStatus" == "PEND" ]
        then
            printf "Job is Pending\n"
        fi
        else
        then
            printf "Job Failed\n"
            store_test_logs
            jobTrackBool=0
        fi
    fi

    if [ $jobTrackBoolSV != 0 ]
    then
        if [ "$leaderStatusSV" == "DONE" ]
        then
            printf "Job SV Finished Successfully\n"
            store_test_logs_sv
            jobTrackBoolSV=0
        elif [ "$leaderStatusSV" == "PEND" ]
        then
            printf "Job SV is Pending\n"
        fi
        else
        then
            printf "Job SV Failed\n"
            store_test_logs_sv
            jobTrackBoolSV=0
        fi
    fi

    if [ $jobTrackBool == 0 ] && [ $jobTrackBoolSV == 0 ]
    then
        if [ "$leaderStatus" == "EXIT" ] && [ "$leaderStatusSV" == "EXIT" ]
        then
            printf "Both Jobs Failed\n"
            store_test_logs
            store_test_logs_sv
            exit 1
        elif [ "$leaderStatus" == "EXIT" ] && [ "$leaderStatusSV" == "DONE" ]
        then
            printf "Regular Workflow Failed; SV Workflow Finished Successfully\n"
            store_test_logs
            store_test_logs_sv
            exit 1
        elif [ "$leaderStatus" == "DONE" ] && [ "$leaderStatusSV" == "EXIT" ]
        then
            printf "Regular Workflow Finished Successfully; SV Workflow Failed\n"
            store_test_logs
            store_test_logs_sv
            exit 1
        fi
    fi
    sleep 1m
done