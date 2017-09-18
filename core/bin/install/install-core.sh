#!/bin/bash

# load settings
source ../../config/settings.sh

# make directories
ROSLIN_CORE_BIN_PATH="${ROSLIN_CORE_PATH}/bin"
ROSLIN_CORE_CONFIG_PATH="${ROSLIN_CORE_PATH}/config"
ROSLIN_CORE_SCHEMA_PATH="${ROSLIN_CORE_PATH}/schemas"

mkdir -p ${ROSLIN_CORE_PATH}
mkdir -p ${ROSLIN_CORE_BIN_PATH}
mkdir -p ${ROSLIN_CORE_CONFIG_PATH}
mkdir -p ${ROSLIN_CORE_SCHEMA_PATH}

# copy scripts
cp -r ../* ${ROSLIN_CORE_BIN_PATH}
cp -r ../../config/* ${ROSLIN_CORE_CONFIG_PATH}
cp -r ../../schemas/* ${ROSLIN_CORE_SCHEMA_PATH}
