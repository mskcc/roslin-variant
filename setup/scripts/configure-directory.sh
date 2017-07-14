#!/bin/bash -e

# load config
source ./settings.sh

# directories for binaries, executables, scripts
mkdir -p ${PRISM_BIN_PATH}/pipeline/${PRISM_VERSION}
mkdir -p ${PRISM_BIN_PATH}/schemas
mkdir -p ${PRISM_BIN_PATH}/tools

mkdir -p ${PRISM_BIN_PATH}/bin/setup
mkdir -p ${PRISM_BIN_PATH}/bin/sing
mkdir -p ${PRISM_BIN_PATH}/bin/prism-runner

if [ "$USE_VAGRANT_BIG_DISK" == "YES" ]
then
    sudo mkdir -p /vagrant/bigdisk/tmp
    ln -snf /vagrant/bigdisk/tmp ${PRISM_BIN_PATH}/tmp
else
    mkdir -p ${PRISM_BIN_PATH}/tmp
fi

# data path (e.g. resources such as genome assemblies)
mkdir -p ${PRISM_DATA_PATH}

# directories for pipeline inputs (e.g. workspace, examples)
mkdir -p ${PRISM_INPUT_PATH}

# create output directory
mkdir -p ${PRISM_OUTPUT_PATH}

# group should have read/write/execute permission
chmod -R 775 ${PRISM_BIN_PATH}/pipeline/${PRISM_VERSION}
chmod -R 775 ${PRISM_BIN_PATH}/schemas
chmod -R 775 ${PRISM_BIN_PATH}/tools
chmod -R 775 ${PRISM_BIN_PATH}/bin/setup
chmod -R 775 ${PRISM_BIN_PATH}/bin/sing
chmod -R 775 ${PRISM_BIN_PATH}/bin/prism-runner

# everyone should have read/write/execute permission
chmod 777 ${PRISM_BIN_PATH}/tmp
chmod 777 ${PRISM_INPUT_PATH}
chmod 777 ${PRISM_OUTPUT_PATH}
