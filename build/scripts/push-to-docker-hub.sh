#!/bin/bash -e

# load build-related settings
source ./settings-build.sh

# load utils
source ./tools-utils.sh

usage()
{
cat << EOF

USAGE: $0 [options]

OPTIONS:

   -t      List of tools to push to Docker Hub (comma-separated list)
           All tools will be pushed to Docker Hub if -t is not specified.                
           
           Example: $0 -t bwa:0.7.12,picard:1.129

   -z      Show list of tools that be built

EOF
}

while getopts “t:zh” OPTION
do
    case $OPTION in
        t) SELECTED_TOOLS_TO_BUILD=$OPTARG ;;
        z) for tool in $(get_tools_name_version); do echo $tool; done; exit 1 ;;        
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

# check if user is logged in to Docker Hub.
# the following command returns auth token if user is authenticated
if sudo test -f ~/.docker/config.json
then
    is_login=`sudo cat ~/.docker/config.json | jq -r ".auths[].auth"`
else
    is_login=""
fi

if [ -z $is_login ]
then
    sudo docker login
    if [ $? -ne 0 ]
    then
        echo "You must be logged in to Docker Hub. Please try again."
        exit 1
    fi
fi

# check if the specified tool are supported one.
for tool_info in $(echo $SELECTED_TOOLS_TO_BUILD | sed "s/,/ /g")
do
    tool_found=$(is_tool_available $tool_info)
    if [ "$tool_found" == "false"  ]
    then
        echo "The tool you specified is not found in the supported tools list."
        usage
        exit 1
    fi
done

if [ -z "$SELECTED_TOOLS_TO_BUILD" ]
then    
    SELECTED_TOOLS_TO_BUILD=$(get_tools_name_version)
fi


for tool_info in $(echo $SELECTED_TOOLS_TO_BUILD | sed "s/,/ /g")
do
    tool_name=$(get_tool_name $tool_info)
    tool_version=$(get_tool_version $tool_info)
    echo "Pushing to Docker Hub: ${tool_name} (version ${tool_version})"

    docker_image_full_name=${DOCKER_REPO_NAME}/${DOCKER_REPO_TOOLNAME_PREFIX}-${tool_info}

    sudo docker tag ${tool_info} ${docker_image_full_name}

    sudo docker push ${docker_image_full_name}
done

