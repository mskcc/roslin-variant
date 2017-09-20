#!/bin/bash -e

# load config
source ./settings.sh

# directories for binaries, executables, scripts
mkdir -p ${ROSLIN_BIN_PATH}/pipeline/${ROSLIN_PIPELINE_VERSION}
mkdir -p ${ROSLIN_BIN_PATH}/schemas
mkdir -p ${ROSLIN_BIN_PATH}/tools

mkdir -p ${ROSLIN_BIN_PATH}/bin/setup
mkdir -p ${ROSLIN_BIN_PATH}/bin/sing
mkdir -p ${ROSLIN_BIN_PATH}/bin/prism-runner

if [ "$USE_VAGRANT_BIG_DISK" == "YES" ]
then
    sudo mkdir -p /vagrant/bigdisk/tmp
    ln -snf /vagrant/bigdisk/tmp ${ROSLIN_BIN_PATH}/tmp
else
    mkdir -p ${ROSLIN_BIN_PATH}/tmp
fi

# data path (e.g. resources such as genome assemblies)
mkdir -p ${ROSLIN_DATA_PATH}

# directories for pipeline inputs (e.g. workspace, examples)
mkdir -p ${ROSLIN_INPUT_PATH}

# create output directory
mkdir -p ${ROSLIN_OUTPUT_PATH}

# group should have read/write/execute permission
chmod -R 775 ${ROSLIN_BIN_PATH}/pipeline/${ROSLIN_PIPELINE_VERSION}
chmod -R 775 ${ROSLIN_BIN_PATH}/schemas
chmod -R 775 ${ROSLIN_BIN_PATH}/tools
chmod -R 775 ${ROSLIN_BIN_PATH}/bin/setup
chmod -R 775 ${ROSLIN_BIN_PATH}/bin/sing
chmod -R 775 ${ROSLIN_BIN_PATH}/bin/prism-runner

# everyone should have read/write/execute permission
chmod 777 ${ROSLIN_BIN_PATH}/tmp
chmod 777 ${ROSLIN_INPUT_PATH}
chmod 777 ${ROSLIN_OUTPUT_PATH}
