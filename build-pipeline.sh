#!/bin/bash
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
USAGE=true
cat << EOF
USAGE: `basename $0` [options]
build.sh
OPTIONS:
   -t                Build the pipeline for testing [optional]
   -c                Clean the working directory for building
   -b [build_id]     Specify a build id [required for testing]
   -f                Force overwrite [optional]
   -h                Print help
EOF
}

parentDir=$(pwd)
script_dir_relative=`dirname "$0"`
script_dir=`python -c "import os; print os.path.abspath('${script_dir_relative}')"`
build_script_dir=${script_dir}/build/scripts

function finish {
    if [ ! -n "$USAGE" ]
    then
        # clean up
        cd $parentDir
        rm -f setup/config/build-settings.sh
        rm -f setup/config/settings.sh
        rm -f core/config/settings.sh
        rm -f build/scripts/settings-container.sh
        if [ -n "$TEST_MODE" ]
        then
            rm -f setup/config/test-settings.sh
            rm -f test/run-example.sh
            rm -f test/run-example-sv.sh
            if [ -n "$CLEAN" ]
            then
                rm -rf test_output/$BUILD_NUMBER
            fi
        else
            if [ -n "$CLEAN" ]
            then
                rm -rf roslin-build-log
            fi
        fi
        if [ -n "$BUILD_IMAGES" ]
        then
            if compareBool $BUILD_IMAGES
            then
                # Cleanup vagrant
                echo "Cleaning up..."
                cleanupCommand="cd ${build_script_dir};./cleanup.sh"
            fi
        fi
    fi
}
trap finish INT TERM EXIT

while getopts "tchb:f" OPTION
do
    case $OPTION in
        t)TEST_MODE=true;;
        c)CLEAN=true;;
        b)BUILD_NUMBER=$OPTARG;;
        f)FORCE=true;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -n "$CLEAN" ]
then
    echo "Cleaning up..."
    rm -rf build-venv
    rm build_images_parallel.log 2> /dev/null
    rm roslin*.tgz 2> /dev/null
    rm -rf roslin-build-log
    rm -rf setup/img/
    exit 0
fi

if [ -n "$TEST_MODE" ] && [ -z "$BUILD_NUMBER" ]
then
    >&2 echo "No build number defined"
    usage;
    exit 1;
fi

if ! [ -x "$(command -v virtualenv)" ]
then
     >&2 echo "Error, virtualenv not installed"
     exit 1;
fi

printf "\n----------Setting Up----------\n"
#Script will exit if a command exits with nonzero exit value
set -e
if [ -d build-venv ]
then
    echo "Overwriting virtualenv"
    rm -r build-venv
fi
virtualenv build-venv
source build-venv/bin/activate
pip install --requirement build/build_requirements.txt

printf "\n----------Starting----------\n"
# Set the config
python $build_script_dir/configure.py config.variant.yaml
# load settings
source setup/config/settings.sh
source setup/config/build-settings.sh

source build-venv/bin/activate

cd core
python configure.py config.core.yaml
# load core settings
source config/settings.sh
cd ..
coreDir=$ROSLIN_CORE_PATH
buildArgs="--t $BUILD_THREADS"
buildScript="${build_script_dir}/build_images_parallel.py"
if compareBool $BUILD_DOCKER
then
    buildArgs="$buildArgs --build_docker"
fi

if compareBool $BUILD_SINGULARITY
then
    buildArgs="$buildArgs --build_singularity"
fi

if compareBool $DOCKER_PUSH
then
    buildArgs="$buildArgs --docker_push"
fi

if [ -n "$DOCKER_REGISTRY" ]
then
    buildArgs="$buildArgs --docker_registry $DOCKER_REGISTRY"
fi

if compareBool $DOCKER_PUSH && [ -z "$DOCKER_REGISTRY" ]
then
    echo "Please specify a dockerRegistry in the config when dockerPush is True"
    exit 1
fi

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
    buildArgs="$buildArgs --d"
else
    printf "Starting Build\n"
    installDir=$ROSLIN_ROOT/$ROSLIN_PIPELINE_NAME
    TempDir=roslin-build-log
    TestDir=roslin-build-log
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

mkdir -p $TempDir

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


cd $parentDir

# Start building the pipeline
printf "\n----------Building----------\n"
if compareBool $USE_VAGRANT
then
    buildCommand="sudo python /vagrant/build/scripts/build_images_parallel.py $buildArgs"
    vagrant up
    vagrant ssh -- -t "$buildCommand"
else
    buildCommand="python $buildScript $buildArgs"
    $buildCommand
fi

printf "\n----------Compressing----------\n"
# Compress pipeline
cd $parentDir
python $build_script_dir/compress.py $ROSLIN_PIPELINE_NAME $ROSLIN_PIPELINE_VERSION > $TestDir/compress_stdout.txt 2> $TestDir/compress_stderr.txt
# Deploy
printf "\n----------Deploying----------\n"
pipeline_name="roslin-${ROSLIN_PIPELINE_NAME}-pipeline-v${ROSLIN_PIPELINE_VERSION}.tgz"
mv $pipeline_name $TempDir
install-pipeline.sh -p $TempDir/$pipeline_name > $TestDir/deploy_stdout.txt 2> $TestDir/deploy_stderr.txt

printf "\n----------Setting up----------\n"
deactivate
cp build/run_requirements.txt $ROSLIN_PIPELINE_DATA_PATH
cp build/scripts/build-node.sh $ROSLIN_PIPELINE_DATA_PATH
source $ROSLIN_CORE_CONFIG_PATH/settings.sh
source $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/settings.sh
/bin/cp $ROSLIN_CORE_CONFIG_PATH/settings.sh $parentDir
cat $ROSLIN_CORE_CONFIG_PATH/$ROSLIN_PIPELINE_NAME/$ROSLIN_PIPELINE_VERSION/settings.sh >> $parentDir/settings.sh
cd $parentDir