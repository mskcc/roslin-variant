#!/bin/bash

export ROSLIN_CORE_VERSION="1.0.0"

# path to all the Roslin Core versions are/will be installed
export ROSLIN_CORE_ROOT="/ifs/work/pi/roslin-core"

# path to all the Roslin Pipelines are/will be installed
export ROSLIN_PIPELINE_INSTALL_PATH="/ifs/work/pi/roslin-pipelines"

# path for a specific version of Roslin Core
export ROSLIN_CORE_PATH="${ROSLIN_CORE_ROOT}/${ROSLIN_CORE_VERSION}"

export ROSLIN_CORE_BIN_PATH="${ROSLIN_CORE_PATH}/bin"
export ROSLIN_CORE_CONFIG_PATH="${ROSLIN_CORE_PATH}/config"

ROSLIN_CORE_SCHEMA_PATH="${ROSLIN_CORE_PATH}/schemas"
