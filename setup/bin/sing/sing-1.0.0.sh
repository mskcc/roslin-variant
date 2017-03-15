#!/bin/bash

# do not echo out anything,
# otherwise sing.sh ... | sing.sh ... won't work

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

# fixme: use full path to singularity
# or read from settings
/usr/local/bin/singularity run \
  --bind ${BIND_BIN} \
  --bind ${BIND_DATA} \
  ${CONTAINER_IMAGE_PATH}/${TOOL_NAME}/${TOOL_VERSION}/${TOOL_NAME}.img $*
