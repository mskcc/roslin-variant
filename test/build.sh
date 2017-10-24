#!/bin/bash
# path to lsf commands
export PATH=$PATH:/common/lsf/9.1/linux2.6-glibc2.3-x86_64/etc:/common/lsf/9.1/linux2.6-glibc2.3-x86_64/bin
# Script will exit if a command exits with nonzero exit value
set -e
# genrate id for test build
printf "\n----------Starting----------\n"
UUID=$(cat /proc/sys/kernel/random/uuid)
printf "$UUID\n"
#dynamically add it to the vagrant file
cp ../Vagrantfile ../Vagrantfile_test
sed -i '$ d' ../Vagrantfile_test
printf "  config.vm.provision \"shell\", run: \"always\", path: \"./test/build-images-and-cwl.sh\", args: \"%s\", privileged: false\nend" "$UUID" >> ../Vagrantfile_test
## set vagrant path correctly
currentDir=$PWD
parentDir="$(dirname "$currentDir")"
export VAGRANT_CWD=$parentDir
export VAGRANT_VAGRANTFILE=Vagrantfile_test
# Set tmp and test directory
export TMPDIR="/srv/scratch/"
export TOIL_LSF_ARGS='-S 1'
TempDir=/srv/scratch/$UUID
TestDir=test_output/$UUID
# Start vagrant to build the pipeline
printf "\n----------Building now----------\n"
vagrant up
# check if build did not fail
cd ..
if [ $(ls $TestDir | grep -c "EXIT") -gt 0 ]
then
exit 1
fi
printf "\n----------Compressing now----------\n"
# Compress pipeline
python test/compress.py $UUID > $TestDir/compress_stdout.txt 2> $TestDir/compress_stderr.txt
# Load roslin core
source /ifs/work/pi/roslin-test/roslin-core/1.0.0/config/settings.sh
# Deploy
printf "\n----------Deploying----------\n"
pipeline_name="roslin-test-pipeline-v${UUID}.tgz"
mkdir $TempDir
mv $pipeline_name $TempDir
cd $TempDir
export PATH=$ROSLIN_CORE_BIN_PATH/install:$PATH
install-pipeline.sh -p $TempDir/$pipeline_name > $parentDir/$TestDir/deploy_stdout.txt 2> $parentDir/$TestDir/deploy_stderr.txt
cd $ROSLIN_CORE_BIN_PATH
# Create workspace
./roslin-workspace-init.sh -v test/$UUID -u jenkins
# Run test
printf "\n----------Running Test----------\n"
cd /ifs/work/pi/roslin-test/roslin-pipelines/test/$UUID/workspace/jenkins/examples/Proj_DEV_0002
#pipelineJobId=$(./run-example.sh | grep '[0-9a-zA-Z]\{8\}-[0-9a-zA-Z]\{4\}-[0-9a-zA-Z]\{4\}-[0-9a-zA-Z]\{4\}-[0-9a-zA-Z]\{12\}')
source /ifs/work/pi/roslin-test/.pyenv/bin/activate
export PATH=$ROSLIN_CORE_BIN_PATH:$PATH
pipelineLeaderId=$(./run-example.sh | grep '[0-9]\{8\}')
printf "$pipelineLeaderId\n"
runningBool=1
while [ $runningBool != 0 ]
do
leaderStatus=$(bjobs $pipelineLeaderId | awk '{print $3}' | tail -1)
printf "$leaderStatus\n"
  if [ "$leaderStatus" == "DONE" ]
    then
    printf "Job Finished successfully\n"
    runningBool=0
  elif [ "$leaderStatus" == "EXIT" ]
    then
    printf "Job Failed\n"
    exit 1
  fi
  sleep 1m
done
