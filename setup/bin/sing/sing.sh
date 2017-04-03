#!/bin/bash

# do not echo out anything,
# otherwise sing.sh ... | sing.sh ... won't work

if [ -z $PRISM_BIN_PATH ] || [ -z $PRISM_DATA_PATH ] || [ -z $PRISM_SINGULARITY_PATH ]
then
    echo "Some of the necessary paths are not correctly configured!"
    echo "PRISM_BIN_PATH=${PRISM_BIN_PATH}"
    echo "PRISM_DATA_PATH=${PRISM_DATA_PATH}"
    echo "PRISM_SINGULARITY_PATH=${PRISM_SINGULARITY_PATH}"
    exit 1
fi

usage()
{
cat << EOF

Usage:     sing.sh <tool-name> <tool-version> [options]

Example:   sing.sh samtools 1.3.1 view sample.bam

EOF
}

BIND_BIN="${PRISM_BIN_PATH}:${PRISM_BIN_PATH}"
BIND_DATA="${PRISM_DATA_PATH}:${PRISM_DATA_PATH}"
CONTAINER_IMAGE_PATH="${PRISM_BIN_PATH}/tools"

if [ -z $1 ] || [ -z $2 ];
then
  usage; exit 1;
fi

TOOL_NAME=$1
shift
TOOL_VERSION=$1
shift

# run singularity
${PRISM_SINGULARITY_PATH} run \
  --bind ${BIND_BIN} \
  --bind ${BIND_DATA} \
  ${CONTAINER_IMAGE_PATH}/${TOOL_NAME}/${TOOL_VERSION}/${TOOL_NAME}.img $*
