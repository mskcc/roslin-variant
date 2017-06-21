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

#fixme: probably not needed
# mkdir -p ${PRISM_BIN_PATH}/bin/singularity
# mkdir -p ${PRISM_BIN_PATH}/bin/cwl
# mkdir -p ${PRISM_BIN_PATH}/bin/cwl/cwl-runner
# mkdir -p ${PRISM_BIN_PATH}/bin/cwl/cwltoil

# user executes cwltoil which creates tmp directories and tmp files.
if [ "$USE_VAGRANT_BIG_DISK" == "YES" ]
then
    sudo mkdir -p /vagrant/bigdisk/tmp
    ln -snf /vagrant/bigdisk/tmp ${PRISM_BIN_PATH}/tmp
else
    mkdir -p ${PRISM_BIN_PATH}/tmp
fi

#fixme: 777 really?
chmod 777 ${PRISM_BIN_PATH}/tmp

# data path (e.g. resources such as genome assemblies)
mkdir -p ${PRISM_DATA_PATH}

# directories for pipeline inputs
mkdir -p ${PRISM_INPUT_PATH}

#fixme: needed for now because other users need to create their own directories (workspace) under this
chmod 777 ${PRISM_INPUT_PATH}

# create output directory
mkdir -p ${PRISM_OUTPUT_PATH}
