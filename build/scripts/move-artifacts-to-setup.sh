#!/bin/bash
script_rel_dir=`dirname ${BASH_SOURCE[0]}`
script_dir=`python -c "import os; print os.path.abspath('${script_rel_dir}')"`
# load utils
source $script_dir/tools-utils.sh
source $script_dir/settings-build.sh

rm -rf ${IMG_DIRECTORY}
mkdir -p ${IMG_DIRECTORY}

# copy over all singularity images whose name/version matches with what's defined in tools.json
all_avail_tools=$(get_tools_name_version)
for tool_info in $(echo $all_avail_tools | sed "s/,/ /g")
do
    tool_name=$(get_tool_name $tool_info)
    tool_version=$(get_tool_version $tool_info)
    tool_output_dir="${IMG_DIRECTORY}/${tool_name}/${tool_version}"

    # don't copy if tool name starts with @
    if [ ${tool_name:0:1} == "@" ]
    then
        continue
    fi

    mkdir -p ${tool_output_dir}

    cp ${CONTAINER_DIRECTORY}/${tool_name}/${tool_version}/${tool_name}.sif ${tool_output_dir}

done

cp ${CONTAINER_DIRECTORY}/images_meta.json ${IMG_DIRECTORY}

echo "--- IMAGE TREE ---"
# show tree
tree ${IMG_DIRECTORY}

# get md5 checksum for all image files
cd ${IMG_DIRECTORY}
find . -name "*.sif" -type f | xargs md5sum > ${IMG_DIRECTORY}/checksum.dat

# get md5 checksum for all cwl files
echo "--- CWL TREE ---"

cd ${CWL_DIRECTORY}
find . -name "*.cwl" -type f | xargs md5sum > ${CWL_DIRECTORY}/checksum.dat
