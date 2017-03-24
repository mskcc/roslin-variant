#!/bin/bash

# load build-related settings
source ./settings-build.sh

# load utils
source ./tools-utils.sh

# load bind points definition
source ./settings-container.sh

TOOLS_TO_CHECK=$(get_tools_name_version)

exit_code=0

for tool_info in $(echo $TOOLS_TO_CHECK | sed "s/,/ /g")
do
    tool_name=$(get_tool_name $tool_info)
    tool_version=$(get_tool_version $tool_info)
    tool_img="${CONTAINER_DIRECTORY}/${tool_name}/${tool_version}/${tool_name}.img"

    echo ${tool_img}

    for bind_point in ${SINGULARITY_BIND_POINTS}
    do
        singularity exec ${tool_img} test -d ${bind_point}
        if [ $? -eq 0 ]
        then
            echo "  - ${bind_point} : OK"
        else
            echo "  - ${bind_point} : NOT FOUND!"
            exit_code=1
        fi
    done

    echo
done

exit $exit_code