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
export NVM_DIR=/ifs/work/pi/roslin-test/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

usage()
{
cat << EOF
USAGE: `basename $0` [options]
build.sh
OPTIONS:
   -t      Build the pipeline for testing [optional]
   -b      Specify a build id [required for testing]
EOF
}
# genrate id for test build

while getopts "tb:" OPTION
do
    case $OPTION in
        t)TEST_MODE=true;;
        b)BUILD_NUMBER=$OPTARG;;
        *) usage; exit 1 ;;
    esac
done

if [ -n "$TEST_MODE" ] && [ -z "$BUILD_NUMBER"]
then
    >&2 echo "No build number defined"
    usage;
    exit 1;
fi

printf "\n----------Setting Up----------\n"

virtualenv $TMPDIR/build-venv --no-site-packages
source $TMPDIR/build-venv/bin/activate
pip install -r build/build_requirements.txt

printf "\n----------Starting----------\n"
# Set the config
python configure.py config.variant.yaml

#Script will exit if a command exits with nonzero exit value
set -e

# load settings
source setup/config/settings.sh
source setup/config/build-settings.sh
parentDir=$pwd

echo $BUILD_THREADS

if [ -n "$TEST_MODE" ]
then    
    source ../setup/config/test-settings.sh
    printf "Starting Build $BUILD_NUMBER\n"    
    installDir=$ROSLIN_TEST_ROOT/$ROSLIN_PIPELINE_NAME/$BUILD_NUMBER
    TempDir=$TMPDIR/$BUILD_NUMBER
    TestDir=$TMPDIR/$BUILD_NUMBER
    coreDir=$installDir/roslin-core
    buildCommand="cd /vagrant/build/scripts/;python /vagrant/build/scripts/build-images-parallel.py -d -t $BUILD_THREADS"
else
    printf "Starting Build\n"
    TempDir=roslin-build-log
    TestDir=roslin-build-log
    installDir=$ROSLIN_ROOT
    coreDir=$installDir/roslin-core
    buildCommand="cd /vagrant/build/scripts/;python build-images-parallel.py -d -t $BUILD_THREADS"
    if [ ! "$INSTALL_CORE" ] && [ ! -d "$coreDir" ] 
    then
        >&2 echo "Could not find Core directory: $coreDir"
        exit 1
    fi
fi

echo $buildCommand



if [ -d "$TempDir" ]
then
    rm -rf $TempDir
    mkdir -p $TempDir
fi

if [ $BUILD_IMAGES ]
then
    sed -i -e "s/40GB/$VAGRANT_SIZE/g" Vagrantfile
    vagrant up
    # Start building the pipeline
    printf "\n----------Building----------\n"
    vagrant ssh -- -t "$buildCommand"
fi

printf "\n----------Setting up workspace----------\n"

# Create the test dir where the pipeline will be installed
mkdir -p $installDir
mkdir -p $coreDir

if [ $INSTALL_CORE ]
then
    printf "\n----------Installing Core----------\n"
    core/configure.py core/config.core.yaml --testBuild
fi
# Load roslin core and pipeline
source core/config/settings.sh
source setup/config/settings.sh
# install core
cd core/bin/install
./install-core.sh
printf "\n----------Compressing----------\n"
# Compress pipeline
cd $parentDir
python compress.py $ROSLIN_PIPELINE_NAME $ROSLIN_PIPELINE_VERSION > $TestDir/compress_stdout.txt 2> $TestDir/compress_stderr.txt
deactivate
# Deploy
printf "\n----------Deploying----------\n"
pipeline_name="roslin-${ROSLIN_PIPELINE_NAME}-pipeline-v${ROSLIN_PIPELINE_VERSION}.tgz"
mv $pipeline_name $TempDir
cd $TempDir
export PATH=$ROSLIN_CORE_BIN_PATH/install:$PATH
install-pipeline.sh -p $TempDir/$pipeline_name > $parentDir/$TestDir/deploy_stdout.txt 2> $parentDir/$TestDir/deploy_stderr.txt
cd $ROSLIN_CORE_BIN_PATH
# Create workspace
./roslin-workspace-init.sh -v $ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION -u $USER
# clean up
rm *-e
rm setup/config/test-settings.sh
rm setup/config/build-settings.sh
rm setup/config/settings.sh
rm core/config/settings.sh