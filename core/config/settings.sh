#!/bin/bash

export ROSLIN_CORE_VERSION="1.0.0"

# path to all the Roslin Core versions are/will be installed
export ROSLIN_CORE_ROOT="/ifs/work/bergerm1/Innovation/sandbox/ian/roslin-core"

# path for a specific version of Roslin Core
export ROSLIN_CORE_PATH="${ROSLIN_CORE_ROOT}/${ROSLIN_CORE_VERSION}"

export ROSLIN_CORE_BIN_PATH="${ROSLIN_CORE_PATH}/bin"
export ROSLIN_CORE_CONFIG_PATH="${ROSLIN_CORE_PATH}/config"

ROSLIN_CORE_SCHEMA_PATH="${ROSLIN_CORE_PATH}/schemas"

export ROSLIN_REDIS_HOST="bale"
export ROSLIN_REDIS_PORT=9006
