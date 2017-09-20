#!/bin/bash

# do not echo out anything,
# otherwise sing.sh ... | sing.sh ... won't work

if [ -z $ROSLIN_BIN_PATH ] || [ -z $ROSLIN_DATA_PATH ] || \
   [ -z $ROSLIN_INPUT_PATH ] || [ -z $ROSLIN_OUTPUT_PATH ] || \
   [ -z "$ROSLIN_EXTRA_BIND_PATH" ] || [ -z $ROSLIN_SINGULARITY_PATH ]
then
    echo "Some of the necessary paths are not correctly configured!"
    echo "ROSLIN_BIN_PATH=${ROSLIN_BIN_PATH}"
    echo "ROSLIN_DATA_PATH=${ROSLIN_DATA_PATH}"
    echo "ROSLIN_EXTRA_BIND_PATH=${ROSLIN_EXTRA_BIND_PATH}"
    echo "ROSLIN_INPUT_PATH=${ROSLIN_INPUT_PATH}"
    echo "ROSLIN_OUTPUT_PATH=${ROSLIN_OUTPUT_PATH}"
    echo "ROSLIN_SINGULARITY_PATH=${ROSLIN_SINGULARITY_PATH}"
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
bind_bin="${ROSLIN_BIN_PATH}:${ROSLIN_BIN_PATH}"
bind_data="${ROSLIN_DATA_PATH}:${ROSLIN_DATA_PATH}"
bind_input="${ROSLIN_INPUT_PATH}:${ROSLIN_INPUT_PATH}"
bind_output="${ROSLIN_OUTPUT_PATH}:${ROSLIN_OUTPUT_PATH}"
bind_extra=""
for extra_path in ${ROSLIN_EXTRA_BIND_PATH}
do
  bind_extra="${bind_extra} --bind ${extra_path}:${extra_path}"
done

# path to container images
container_image_path="${ROSLIN_BIN_PATH}/img"

while getopts “i” OPTION
do
    case $OPTION in
        i) inspect="set" ;;
    esac
done

tool_name=${@:$OPTIND:1}
tool_version=${@:$OPTIND+1:1}

if [ -z "$tool_name" ] || [ -z "$tool_version" ];
then
  usage; exit 1;
fi

shift
shift

# output metadata (labels) if the inspect option (-i) is supplied
if [ "$inspect" = "set" ]
then
  env -i ${ROSLIN_SINGULARITY_PATH} exec \
    ${container_image_path}/${tool_name}/${tool_version}/${tool_name}.img \
    cat /.roslin/labels.json
  exit $?
fi

# start a singularity container with an empty environment by runnning with env -i
env -i ${ROSLIN_SINGULARITY_PATH} run \
  --bind ${bind_bin} \
  --bind ${bind_data} \
  --bind ${bind_input} \
  --bind ${bind_output} \
  ${bind_extra} \
  ${container_image_path}/${tool_name}/${tool_version}/${tool_name}.img $*
