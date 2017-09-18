#!/bin/bash

${OUTPUT_DIRECTORY}=$1

# set up singularity bind paths
bind_bin="${ROSLIN_BIN_PATH}:${ROSLIN_BIN_PATH}"
bind_data="${ROSLIN_DATA_PATH}:${ROSLIN_DATA_PATH}"
bind_extra=""
for extra_path in ${ROSLIN_EXTRA_BIND_PATH}
do
  bind_extra="${bind_extra} --bind ${extra_path}:${extra_path}"
done

# check output directory can be accessible from containers
${ROSLIN_SINGULARITY_PATH} exec \
    --bind ${bind_bin} \
    --bind ${bind_data} \
    ${bind_extra} \
    ${ROSLIN_BIN_PATH}/tools/1.0.0/roslin.img test -d ${OUTPUT_DIRECTORY}

if [ $? -ne 0 ]
then
    echo "The specified output directory must be accessible from containers: ${OUTPUT_DIRECTORY}"
    exit 1
fi
