#!/bin/bash

${OUTPUT_DIRECTORY}=$1

# set up singularity bind paths
bind_bin="${PRISM_BIN_PATH}:${PRISM_BIN_PATH}"
bind_data="${PRISM_DATA_PATH}:${PRISM_DATA_PATH}"
bind_extra=""
for extra_path in ${PRISM_EXTRA_BIND_PATH}
do
  bind_extra="${bind_extra} --bind ${extra_path}:${extra_path}"
done

# check output directory can be accessible from containers
${PRISM_SINGULARITY_PATH} exec \
    --bind ${bind_bin} \
    --bind ${bind_data} \
    ${bind_extra} \
    ${PRISM_BIN_PATH}/tools/1.0.0/roslin.img test -d ${OUTPUT_DIRECTORY}

if [ $? -ne 0 ]
then
    echo "The specified output directory must be accessible from containers: ${OUTPUT_DIRECTORY}"
    exit 1
fi
