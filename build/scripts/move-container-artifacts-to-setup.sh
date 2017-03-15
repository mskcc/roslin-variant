#!/bin/bash

######################################
## RUN THIS FROM INSIDE VAGRANT BOX
######################################

# load build-related settings
source ./settings-build.sh

# load utils
source ./tools-utils.sh

OUTPUT_ROOT_DIR="/vagrant/setup/tools"

rm -rf ${OUTPUT_ROOT_DIR}
mkdir -p ${OUTPUT_ROOT_DIR}

# copy over all singularity images whose name/version matches with what's defined in tools.json
all_avail_tools=$(get_tools_name_version)
for tool_info in $(echo $all_avail_tools | sed "s/,/ /g")
do
    tool_name=$(get_tool_name $tool_info)
    tool_version=$(get_tool_version $tool_info)
    tool_output_dir="${OUTPUT_ROOT_DIR}/${tool_name}/${tool_version}"

    mkdir -p ${tool_output_dir}

    cp ${CONTAINER_DIRECTORY}/${tool_name}/${tool_version}/${tool_name}.img ${tool_output_dir}

done

# show tree
tree ${OUTPUT_ROOT_DIR}

# get md5 checksum for all image files
cd ${OUTPUT_ROOT_DIR}
find . -name "*.img" -type f | xargs md5sum > ${OUTPUT_ROOT_DIR}/checksum.dat
