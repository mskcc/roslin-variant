#!/bin/bash

######################################
## RUN THIS FROM INSIDE VAGRANT BOX
######################################

# load build-related settings
source ./settings-build.sh

# load utils
source ./tools-utils.sh

OUTPUT_ROOT_DIR="/vagrant/setup/cwl-wrappers/${PIPELINE_VERSION}"

mkdir -p ${OUTPUT_ROOT_DIR}

# copy over all cwl wrappers whose name/version/cmo matches with what's defined in tools.json
all_avail_tools=$(get_tools_name_version_cmo)
for tool_info in $(echo $all_avail_tools | sed "s/,/ /g")
do
    tool_name=$(get_tool_name $tool_info)
    tool_version=$(get_tool_version $tool_info)
    cmo_wrapper=$(get_cmo_wrapper_name $tool_info)
    cmo_wrapper_with_dash=`echo "${cmo_wrapper}" | sed "s/_/-/g"`
    cmo_output_dir="${OUTPUT_ROOT_DIR}/${cmo_wrapper_with_dash}/${tool_version}"

    if [ ! -e ${CWL_WRAPPER_DIRECTORY}/${cmo_wrapper_with_dash}/${tool_version}/${cmo_wrapper_with_dash}.cwl ]
    then
        continue
    fi

    # delete and recreate output directory
    rm -rf ${cmo_output_dir}
    mkdir -p ${cmo_output_dir}

    cp ${CWL_WRAPPER_DIRECTORY}/${cmo_wrapper_with_dash}/${tool_version}/${cmo_wrapper_with_dash}.cwl ${cmo_output_dir}

done

# copy prism_resources.json
cp ${CWL_WRAPPER_DIRECTORY}/prism_resources.json ${OUTPUT_ROOT_DIR}

# show tree
tree ${OUTPUT_ROOT_DIR}

# get md5 checksum for all image files
cd ${OUTPUT_ROOT_DIR}
find . -name "*.cwl" -type f | xargs md5sum > ${OUTPUT_ROOT_DIR}/checksum.dat
