#!/bin/bash -e

# load config
source ./settings.sh

# directories for pipeline inputs
if [ -z $USE_VAGRANT_BIG_DISK ]
then
    mkdir -p ${PRISM_INPUT_PATH}/chunj
else
    sudo mkdir -p /vagrant/bigdisk/chunj
    ln -snf /vagrant/bigdisk/chunj ${PRISM_INPUT_PATH}/chunj
fi

# directories for pipeline outputs
mkdir -p ${PRISM_INPUT_PATH}/chunj/outputs

# copy and configure input data
cp ../data/inputs/* ${PRISM_INPUT_PATH}/chunj
chmod -R g+rw ${PRISM_INPUT_PATH}/chunj


# hack: local vm doesn't have enough ram/cores
if [ "$PRISM_SYSTEM_WIDE_INSTALL" == "YES" ]
then
    find ${PRISM_BIN_PATH}/pipeline/${PRISM_VERSION} -name "*.cwl" | xargs -I {} sudo sed -i.bak "s/ramMin: .*/ramMin: 5/g" {}
    find ${PRISM_BIN_PATH}/pipeline/${PRISM_VERSION} -name "*.cwl" | xargs -I {} sudo sed -i.bak "s/coresMin: .*/coresMin: 1/g" {}
else
    find ${PRISM_BIN_PATH}/pipeline/${PRISM_VERSION} -name "*.cwl" | xargs -I {} sed -i.bak "s/ramMin: .*/ramMin: 5/g" {}
    find ${PRISM_BIN_PATH}/pipeline/${PRISM_VERSION} -name "*.cwl" | xargs -I {} sed -i.bak "s/coresMin: .*/coresMin: 1/g" {}
fi
