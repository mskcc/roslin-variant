#!/bin/bash

# load settings
source ../../config/settings.sh

mkdir -p ${ROSLIN_CORE_PATH}
mkdir -p ${ROSLIN_CORE_BIN_PATH}
mkdir -p ${ROSLIN_CORE_CONFIG_PATH}
mkdir -p ${ROSLIN_CORE_SCHEMA_PATH}

# copy scripts
cp -r ../* ${ROSLIN_CORE_BIN_PATH}
cp -r ../../config/* ${ROSLIN_CORE_CONFIG_PATH}
cp -r ../../schemas/* ${ROSLIN_CORE_SCHEMA_PATH}
cp ${ROSLIN_CORE_BIN_PATH}/roslin-project-status.sh ${ROSLIN_CORE_BIN_PATH}/bjp

# give write permission
chmod -R g+w ${ROSLIN_CORE_BIN_PATH}/install

echo "DONE."
