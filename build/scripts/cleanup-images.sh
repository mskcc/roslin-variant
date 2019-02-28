#!/bin/bash

# load build-related settings
source ./settings-build.sh

# load utils
source ./tools-utils.sh

# delete singularity images created
find ${CONTAINER_DIRECTORY}/ -name '*.sif' -type f -delete

# delete docker images whose name is not set
sudo docker images --format '{{.Repository}}\t{{.ID}}' | grep "<none>" | awk -F'\t' '{ print $2 }' | xargs sudo docker rmi -f

# delete docker images whose name/version matches with what's defined in tools.json
all_avail_tools=$(get_tools_name_version)
for tool_info in $(echo $all_avail_tools | sed "s/,/ /g")
do
    sudo docker rmi ${tool_info} -f
    sudo docker images ${DOCKER_REPO_NAME}/${DOCKER_REPO_TOOLNAME_PREFIX}-${tool_info} --format '{{.ID}}' | xargs sudo docker rmi -f
    sudo docker images localhost:5000/${DOCKER_REPO_TOOLNAME_PREFIX}-${tool_info} --format '{{.ID}}' | xargs sudo docker rmi -f
done