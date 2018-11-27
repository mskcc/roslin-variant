#! /bin/bash

# load build-related settings
source ./settings-build.sh

# load utils
source ./tools-utils.sh


usage()
{
cat << EOF

USAGE: $0 [options]

OPTIONS:

   -t      List of tools to build (comma-separated list)
           All pre-defined tools will be built if -t is not specified.

           Example: $0 -t bwa:0.7.12,picard:1.129

   -z      Show list of tools that be built

EOF
}

while getopts “t::h” OPTION
do
    case $OPTION in
        t) SELECTED_TOOLS_TO_BUILD=$OPTARG ;;
        z) for tool in $(get_tools_name_version); do echo $tool; done; exit 1 ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

for tool_info in $(echo $SELECTED_TOOLS_TO_BUILD | sed "s/,/ /g")
do
    tool_name=$(get_tool_name $tool_info)
    tool_version=$(get_tool_version $tool_info)

    # don't build if tool name starts with @
    if [ ${tool_name:0:1} == "@" ]
    then
        continue
    fi

    docker_image=${DOCKER_REPO_NAME}/${DOCKER_REPO_TOOLNAME_PREFIX}-${tool_info} 

    echo "Building singularity image: ${tool_name} (version ${tool_version})"

    INSTALL_DIR=${ROSLIN_PIPELINE_BIN_PATH}/img/${tool_name}/${tool_version}/
    mkdir -p $INSTALL_DIR
    cd $INSTALL_DIR

    $ROSLIN_SINGULARITY_PATH build ${tool_name}.sif docker://$docker_image

done
