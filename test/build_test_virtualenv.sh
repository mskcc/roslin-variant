#!/bin/bash
# path to lsf commands
# Set LSF env
export LSF_LIBDIR=/common/lsf/9.1/linux2.6-glibc2.3-x86_64/lib
export LSF_SERVERDIR=/common/lsf/9.1/linux2.6-glibc2.3-x86_64/etc
export LSF_BINDIR=/common/lsf/9.1/linux2.6-glibc2.3-x86_64/bin
export LSF_ENVDIR=/common/lsf/conf
export PATH=$PATH:/common/lsf/9.1/linux2.6-glibc2.3-x86_64/etc:/common/lsf/9.1/linux2.6-glibc2.3-x86_64/bin 
# Set python env
export PATH=/opt/common/CentOS_6-dev/python/python-2.7.10/bin/:/opt/common/CentOS_6-dev/bin/current/:$PATH
#Script will exit if a command exits with nonzero exit value
set -e
# genrate id for test build
printf "\n----------Starting----------\n"
#UUID=$(cat /proc/sys/kernel/random/uuid)
#printf "$UUID\n"
printf "Starting Build $BUILD_NUMBER\n"
# dynamically add it to the vagrant file
cp ../Vagrantfile ../Vagrantfile_test
sed -i '$ d' ../Vagrantfile_test
# set the config to point to the right workspace
installDir=/ifs/work/pi/roslin-test/targeted-variants/$BUILD_NUMBER
coreDir=$installDir/roslin-core
sed -i "s|/ifs/work/pi/roslin-pipelines|${installDir}/roslin-pipelines|g" ../config.variant.yaml
printf "  config.vm.provision \"shell\", run: \"always\", path: \"./test/build-images-and-cwl.sh\", args: \"%s\", privileged: false\nend\n" "$BUILD_NUMBER" >> ../Vagrantfile_test
## set vagrant path correctly
currentDir=$PWD
parentDir="$(dirname "$currentDir")"
export VAGRANT_CWD=$parentDir
export VAGRANT_VAGRANTFILE=Vagrantfile_test
# Set tmp and test directory
export TMPDIR="/srv/scratch/"
export TMP="/srv/scratch/"
export TOIL_LSF_ARGS='-S 1'
TempDir=/srv/scratch/$BUILD_NUMBER
TestDir=test_output/$BUILD_NUMBER
# Start vagrant to build the pipeline
printf "\n----------Building----------\n"
vagrant up
# check if build did not fail
cd ..
if [ $(ls $TestDir | grep -c "EXIT") -gt 0 ]
then
exit 1
fi
printf "\n----------Setting up workspace----------\n"
# Create the test dir where the pipeline will be installed
mkdir -p $installDir
mkdir -p $coreDir
printf "\n----------Installing Core----------\n"
source core/config/settings.sh
# Set test specific core
sed -i "s|${ROSLIN_CORE_ROOT}|${coreDir}|g" core/config/settings.sh
# Load roslin core and pipeline
source core/config/settings.sh
source setup/config/settings.sh
# install core
cd core/bin/install
./install-core.sh
printf "\n----------Compressing----------\n"
# Compress pipeline
cd $parentDir
python test/compress.py $ROSLIN_PIPELINE_NAME $ROSLIN_PIPELINE_VERSION > $TestDir/compress_stdout.txt 2> $TestDir/compress_stderr.txt
# Deploy
printf "\n----------Deploying----------\n"
pipeline_name="roslin-${ROSLIN_PIPELINE_NAME}-pipeline-v${ROSLIN_PIPELINE_VERSION}.tgz"
mkdir $TempDir
mv $pipeline_name $TempDir
cd $TempDir
export PATH=$ROSLIN_CORE_BIN_PATH/install:$PATH
install-pipeline.sh -p $TempDir/$pipeline_name > $parentDir/$TestDir/deploy_stdout.txt 2> $parentDir/$TestDir/deploy_stderr.txt
cd $ROSLIN_CORE_BIN_PATH
# Create workspace
./roslin-workspace-init.sh -v $ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION -u jenkins

# Setup virtualenv
printf "\n----------Setting up virtualenv----------\n"
cd $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION
/opt/common/CentOS_6-dev/python/python-2.7.10/bin/virtualenv virtualenv
source virtualenv/bin/activate
export PATH=$ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/virtualenv/bin/:$PATH
pip install -r $installDir/roslin-pipelines/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/bin/scripts/requirements.txt
# install toil
printf "Installing toil..."
cp -r $ROSLIN_TOIL_INSTALL_PATH $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/toil
cd $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/toil
make prepare
make develop extras=[cwl]
# install cmo
printf "Installing cmo..."
cp -r $ROSLIN_CMO_INSTALL_PATH $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/cmo
cd $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/cmo
python setup.py install
#deactivate
printf "Moving cwd to $ROSLIN_CORE_BIN_PATH"
cd $ROSLIN_CORE_BIN_PATH

# Run test
printf "\n----------Running Test----------\n"
printf "Copying from template scripts...\n"
cp $parentDir/test/run-pipeline.sh.template $parentDir/$TestDir/run-pipeline.sh

printf "Adding pipeline names and versions...\n"
sed -i "s/PIPELINE_NAME/$ROSLIN_PIPELINE_NAME/g" $parentDir/$TestDir/run-pipeline.sh
sed -i "s/PIPELINE_VERSION/$ROSLIN_PIPELINE_VERSION/g" $parentDir/$TestDir/run-pipeline.sh

printf "Moving to test directories...\n"
cd $installDir/roslin-pipelines/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/workspace/jenkins/examples/Proj_DEV_0003
cp $parentDir/$TestDir/run-pipeline.sh .

export PATH=$ROSLIN_CORE_BIN_PATH:$PATH
export NVM_DIR=/ifs/work/pi/roslin-test/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

function store_test_logs {
    cd $installDir/roslin-pipelines/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/outputs
    cd $(ls -d */|head -n 1)
    cd $(ls -d */|head -n 1)
    cp stderr.log $parentDir/$TestDir/test_stderr.txt
    cp stdout.log $parentDir/$TestDir/test_stdout.txt
}

function store_test_logs_sv {
    cd $installDir/roslin-pipelines/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/outputs
    cd $(ls -d */ | tail -n 1)
    cd $(ls -d */ | head -n 1)
    cp stderr.log $parentDir/$TestDir/test_stderr_sv.txt
    cp stdout.log $parentDir/$TestDir/test_stdout_sv.txt
}

function store_test_logs_run_pipeline {
    cd $installDir/roslin-pipelines/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/outputs
    cd $(ls -d */ | tail -n 1)
    cd $(ls -d */ | head -n 1)
    cp stderr.log $parentDir/$TestDir/test_stderr_run_pipeline.txt
    cp stdout.log $parentDir/$TestDir/test_stdout_run_pipeline.txt
}

printf "Monitoring job runs...\n"
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

deactivate
