#!/bin/bash

######################################
## RUN THIS FROM INSIDE VAGRANT BOX
######################################

# load build-related settings
source ./settings-build.sh

# load utils
source ./tools-utils.sh

output_root_dir="/vagrant/setup/cwl"

mkdir -p ${output_root_dir}

# copy over all cwl wrappers whose name/version/cmo matches with what's defined in tools.json
all_avail_tools=$(get_tools_name_version_cmo)
for tool_info in $(echo $all_avail_tools | sed "s/,/ /g")
do
    tool_name=$(get_tool_name $tool_info)
    tool_version=$(get_tool_version $tool_info)
    cmo_wrapper=$(get_cmo_wrapper_name $tool_info)
    cmo_wrapper_with_dash=`echo "${cmo_wrapper}" | sed "s/_/-/g"`
    cmo_output_dir="${output_root_dir}/${cmo_wrapper_with_dash}/${tool_version}"

    if [ ! -e ${CWL_WRAPPER_DIRECTORY}/${cmo_wrapper_with_dash}/${tool_version}/${cmo_wrapper_with_dash}.cwl ]
    then
        continue
    fi

    # delete and recreate output directory
    rm -rf ${cmo_output_dir}
    mkdir -p ${cmo_output_dir}

    cp ${CWL_WRAPPER_DIRECTORY}/${cmo_wrapper_with_dash}/${tool_version}/${cmo_wrapper_with_dash}.cwl ${cmo_output_dir}

done

# copy roslin_resources.json
cp ${CWL_WRAPPER_DIRECTORY}/roslin_resources.json ${output_root_dir}

# show tree
tree ${output_root_dir}

# get md5 checksum for all image files
cd ${output_root_dir}
find . -name "*.cwl" -type f | xargs md5sum > ${output_root_dir}/checksum.dat
