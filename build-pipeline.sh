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
function finish {
    # clean up
    cd $parentDir
    rm -f setup/config/build-settings.sh
    rm -f setup/config/settings.sh
    rm -f core/config/settings.sh
    rm -f build/scripts/settings-container.sh
    if [ ! -n "$TEST_MODE" ]
    then
        rm -f setup/config/test-settings.sh
        rm -f test/run-example.sh
        rm -f test/run-example-sv.sh
    fi

}
trap finish INT TERM EXIT
compareBool() {
    if [ $1 = "y" ] || [ $1 = "Y" ] || [ $1 = "yes" ] || [ $1 = "Yes" ] || [ $1 = "YES" ] || [ $1 =  "true" ] || [ $1 = "True" ] || [ $1 = "TRUE" ] || [ $1 = "on" ] || [ $1 = "On" ] || [ $1 = "ON" ]
    then
        true
    elif [ $1 = "n" ] || [ $1 = "N" ] || [ $1 = "no" ] || [ $1 = "No" ] || [ $1 = "NO" ] || [ $1 = "false" ] || [ $1 = "False" ] || [ $1 = "FALSE" ] || [ $1 = "off" ] || [ $1 = "Off" ] || [ $1 = "OFF" ]
    then
        false
    else
        echo "Invalid input: $1, Please use a yaml accepted value for true/false: y,Y,yes,Yes,YES,n,N,no,No,NO,true,True,TRUE,false,False,FALSE,on,On,ON,off,Off,OFF"
        exit 1
    fi    
}

usage()
{
cat << EOF
USAGE: `basename $0` [options]
build.sh
OPTIONS:
   -t                Build the pipeline for testing [optional]
   -b [build_id]     Specify a build id [required for testing]
   -f                Force overwrite [optional]
   -h                Print help
EOF
}
# genrate id for test build

while getopts "thb:f" OPTION
do
    case $OPTION in
        t)TEST_MODE=true;;
        b)BUILD_NUMBER=$OPTARG;;
        f)FORCE=true;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -n "$TEST_MODE" ] && [ -z "$BUILD_NUMBER" ]
then
    >&2 echo "No build number defined"
    usage;
    exit 1;
fi

printf "\n----------Setting Up----------\n"
#Script will exit if a command exits with nonzero exit value
set -e

parentDir=$(pwd)

virtualenv build-venv --no-site-packages
source build-venv/bin/activate
pip install -r build/build_requirements.txt

printf "\n----------Starting----------\n"
# Set the config
python configure.py config.variant.yaml
# load settings
source setup/config/settings.sh
source setup/config/build-settings.sh

cd core
python configure.py config.core.yaml
# load core settings
source config/settings.sh
cd ..
coreDir=$ROSLIN_CORE_PATH

if [ -n "$TEST_MODE" ]
then   
    source setup/config/test-settings.sh
    printf "Starting Build $BUILD_NUMBER\n"    
    installDir=$ROSLIN_TEST_ROOT/$ROSLIN_PIPELINE_NAME/$BUILD_NUMBER
    TempDir=test_output/$BUILD_NUMBER
    TestDir=test_output/$BUILD_NUMBER
    TestCoreDir=$installDir/roslin-core
    sed -i "s|${ROSLIN_ROOT}|${installDir}|g" setup/config/settings.sh
    sed -i "s|${ROSLIN_CORE_ROOT}|${TestCoreDir}|g" core/config/settings.sh
    source setup/config/settings.sh
    source core/config/settings.sh
    coreDir=$ROSLIN_CORE_PATH
    buildCommand="cd /vagrant/build/scripts/;python /vagrant/build/scripts/build-images-parallel.py -d -t $BUILD_THREADS"
else
    printf "Starting Build\n"
    installDir=$ROSLIN_PIPELINE_ROOT
    TempDir=roslin-build-log
    TestDir=roslin-build-log
    buildCommand="cd /vagrant/build/scripts/;python build-images-parallel.py -t $BUILD_THREADS"
    if ! compareBool $INSTALL_CORE && [ ! -d "$coreDir" ] 
    then
        >&2 echo "Could not find Core directory: $coreDir"
        exit 1
    fi
fi

if compareBool $INSTALL_CORE && [ -d "$coreDir" ]
then
    if [ ! -n "$FORCE" ]
    then
    echo "Core is already installed at: $coreDir, use -f to overwrite"
    exit 1
    else
    rm -rf $coreDir
    fi
fi

if [ -d "$ROSLIN_PIPELINE_ROOT" ]    
then
    if [ ! -n "$FORCE" ]
    then
    echo "Pipeline is already installed at: $ROSLIN_PIPELINE_ROOT, use -f to overwrite"
    exit 1
    else
    rm -rf $ROSLIN_PIPELINE_ROOT
    fi
fi

ROSLIN_CONFIG=${ROSLIN_CORE_CONFIG_PATH}/${ROSLIN_PIPELINE_NAME}/${ROSLIN_PIPELINE_VERSION}

if [ -d "$ROSLIN_CONFIG" ]    
then
    if [ ! -n "$FORCE" ]
    then
    echo "Pipeline is already linked to core at: $ROSLIN_CONFIG, use -f to overwrite"
    exit 1
    else
    rm -rf $ROSLIN_CONFIG
    fi
fi
# Make the directory to store the logs
if [ -d "$TempDir" ]
then
    rm -rf $TempDir    
fi

cd $parentDir
mkdir -p $TempDir

if compareBool $BUILD_IMAGES
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

# Install Core
if compareBool $INSTALL_CORE
then
    cd core
    printf "\n----------Installing Core----------\n" 
    cd bin/install
    ./install-core.sh
fi

printf "\n----------Compressing----------\n"
# Compress pipeline
cd $parentDir
python compress.py $ROSLIN_PIPELINE_NAME $ROSLIN_PIPELINE_VERSION > $TestDir/compress_stdout.txt 2> $TestDir/compress_stderr.txt
deactivate
# Deploy
printf "\n----------Deploying----------\n"
pipeline_name="roslin-${ROSLIN_PIPELINE_NAME}-pipeline-v${ROSLIN_PIPELINE_VERSION}.tgz"
mv $pipeline_name $TempDir
export PATH=$ROSLIN_CORE_BIN_PATH/install:$PATH
install-pipeline.sh -p $TempDir/$pipeline_name > $TestDir/deploy_stdout.txt 2> $TestDir/deploy_stderr.txt
cd $ROSLIN_CORE_BIN_PATH
# Create workspace
./roslin-workspace-init.sh -v $ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION -u $USER
# Setup virtualenv
printf "\n----------Setting up virtualenv----------\n"
cd $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION
virtualenv virtualenv --system-site-packages
source virtualenv/bin/activate
export PATH=$ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/virtualenv/bin/:$PATH
cd $parentDir
pip install -r build/run_requirements.txt
# install toil
cp -r $ROSLIN_TOIL_INSTALL_PATH $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/toil
cd $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/toil
make prepare
make develop extras=[cwl]
# install cmo
cp -r $ROSLIN_CMO_INSTALL_PATH $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/cmo
cd $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/cmo
python setup.py install
deactivate
cd $ROSLIN_CORE_BIN_PATH
