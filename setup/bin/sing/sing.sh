#!/bin/bash

# do not echo out anything,
# otherwise sing.sh ... | sing.sh ... won't work

if [ -z $PRISM_BIN_PATH ] || [ -z $PRISM_DATA_PATH ] || [ -z $PRISM_SINGULARITY_PATH ] || [ -z "$PRISM_EXTRA_BIND_PATH" ]
then
    echo "Some of the necessary paths are not correctly configured!"
    echo "PRISM_BIN_PATH=${PRISM_BIN_PATH}"
    echo "PRISM_DATA_PATH=${PRISM_DATA_PATH}"
    echo "PRISM_EXTRA_BIND_PATH=${PRISM_EXTRA_BIND_PATH}"
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

# set up singularity bind paths
bind_bin="${PRISM_BIN_PATH}:${PRISM_BIN_PATH}"
bind_data="${PRISM_DATA_PATH}:${PRISM_DATA_PATH}"
bind_extra=""
for extra_path in ${PRISM_EXTRA_BIND_PATH}
do
  bind_extra="${bind_extra} --bind ${extra_path}:${extra_path}"
done

# path to container images
container_image_path="${PRISM_BIN_PATH}/tools"

if [ -z $1 ] || [ -z $2 ];
then
  usage; exit 1;
fi

tool_name=$1
shift
tool_version=$1
shift

# run singularity
# echo "${PRISM_SINGULARITY_PATH} run --bind ${bind_bin} --bind ${bind_data} ${bind_extra} ${container_image_path}/${tool_name}/${tool_version}/${tool_name}.img $*"

${PRISM_SINGULARITY_PATH} run \
  --bind ${bind_bin} \
  --bind ${bind_data} \
  ${bind_extra} \
  ${container_image_path}/${tool_name}/${tool_version}/${tool_name}.img $*
