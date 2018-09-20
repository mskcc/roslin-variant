#!/bin/bash

######################################
## RUN THIS FROM INSIDE VAGRANT BOX
######################################

# load build-related settings
source ./settings-build.sh

# load utils
source ./tools-utils.sh

output_root_dir="/vagrant/setup/img"

rm -rf ${output_root_dir}
mkdir -p ${output_root_dir}

# copy over all singularity images whose name/version matches with what's defined in tools.json
all_avail_tools=$(get_tools_name_version)
for tool_info in $(echo $all_avail_tools | sed "s/,/ /g")
do
    tool_name=$(get_tool_name $tool_info)
    tool_version=$(get_tool_version $tool_info)
    tool_output_dir="${output_root_dir}/${tool_name}/${tool_version}"

    # don't copy if tool name starts with @
    if [ ${tool_name:0:1} == "@" ]
    then
        continue
    fi

    mkdir -p ${tool_output_dir}

    cp ${CONTAINER_DIRECTORY}/${tool_name}/${tool_version}/${tool_name}.img ${tool_output_dir}

done

# show tree
tree ${output_root_dir}

# get md5 checksum for all image files
cd ${output_root_dir}
find . -name "*.img" -type f | xargs md5sum > ${output_root_dir}/checksum.dat
