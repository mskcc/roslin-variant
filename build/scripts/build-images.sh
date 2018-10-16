#!/bin/bash -e

# load build-related settings
source ./settings-build.sh

# load utils
source ./tools-utils.sh

# flag for building docker images only
BUILD_DOCKER_IMAGE_ONLY=0

# padding size (in megabytes)
# Singularity requires little more space than what Docker needs
PADDING_SIZE=20

# by default, we will utilize docker cache to build images, which runs faster
BUILD_NO_CACHE="false"

usage()
{
cat << EOF

USAGE: $0 [options]

OPTIONS:

   -t      List of tools to build (comma-separated list)
           All pre-defined tools will be built if -t is not specified.

           Example: $0 -t bwa:0.7.12,picard:1.129

   -d      Build docker images only
           This will exclude the docker push, convert to singularity steps.

   -z      Show list of tools that be built

   -s      Override the padding size (default=${PADDING_SIZE} MiB)

   -n      No cache: images will be built from scratch

EOF
}

while getopts “t:dzs:nh” OPTION
do
    case $OPTION in
        t) SELECTED_TOOLS_TO_BUILD=$OPTARG ;;
        d) BUILD_DOCKER_IMAGE_ONLY=1 ;;
        z) for tool in $(get_tools_name_version); do echo $tool; done; exit 1 ;;
        s) PADDING_SIZE=$OPTARG ;;
        n) BUILD_NO_CACHE="true" ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

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

function convert_to_mib {
    local mib=$1
    if [ $2 = "KB" ]
    then
        # if less than 1 MiB, just return 1 MiB
        mib=1
    fi

    if [ $2 = "GB" ]
    then
        # if GiB, convert to MiB
        mib=`echo "$1 * 1000" | bc -l`
    fi
    echo $mib
}

function get_docker_size_in_mib {
    # get docker image size for a given name $1
    # if there are more than two images found for a given name, we will use the first appearing one
    # returned string would look like '3.98 MB'
    local size_string=`sudo docker images $1 --format "{{.Size}}" | head -1`

    # split at the space char, take the numeric portion, add extra 20 MiB ($PADDING_SIZE), and round up
    # fixme: round up done using python script
    local size=`echo ${size_string} | awk -F' ' '{ print $1 }' | python -c "print int(round(float(raw_input()) + $2))"`

    # split at the space char, take the unit portion (e.g. B, KB, MB, GB)
    local size_unit=`echo ${size_string} | awk -F' ' '{ print $2 }'`

    # express in MiB
    size=$(convert_to_mib ${size} ${size_unit})

    echo ${size}
}

for tool_info in $(echo $SELECTED_TOOLS_TO_BUILD | sed "s/,/ /g")
do
    tool_name=$(get_tool_name $tool_info)
    tool_version=$(get_tool_version $tool_info)

    # don't build if tool name starts with @
    if [ ${tool_name:0:1} == "@" ]
    then
        continue
    fi

    echo "Building: ${tool_name} (version ${tool_version})"

    docker_image_full_name="localhost:5000/${DOCKER_REPO_TOOLNAME_PREFIX}-${tool_info}"

    # add --quite to make it less verbose
    sudo docker build --no-cache=${BUILD_NO_CACHE} -t ${tool_info} ${CONTAINER_DIRECTORY}/${tool_name}/${tool_version}

    if [ $BUILD_DOCKER_IMAGE_ONLY -eq 1 ]
    then
        continue
    fi

    sudo docker tag ${tool_info} ${docker_image_full_name}

    # sudo docker login
    sudo docker push ${docker_image_full_name}

    sudo rm -rf /tmp/${tool_name}/${tool_version}
    mkdir -p /tmp/${tool_name}/${tool_version}

    export SINGULARITY_NOHTTPS="y"
    # bootstrap the image
    sudo -E singularity build --sandbox --force \
        /tmp/${tool_name}/${tool_version}/${tool_name} \
        ${CONTAINER_DIRECTORY}/${tool_name}/${tool_version}/Singularity

    # create /.roslin/ directory
    sudo -E singularity exec --writable /tmp/${tool_name}/${tool_version}/${tool_name} mkdir /.roslin/
    # retrieve labels from docker image and save to labels.json
    sudo docker inspect ${tool_info} | sudo jq .[0].Config.Labels > /tmp/${tool_name}/${tool_version}/${tool_name}/.roslin/labels.json

    # compress the image and build in non-shared directory 
    # mmap does not like images being built on a shared directory   

    sudo -E singularity build --force /tmp/${tool_name}/${tool_version}/${tool_name}.sif /tmp/${tool_name}/${tool_version}/${tool_name}
    sudo mv /tmp/${tool_name}/${tool_version}/${tool_name}.sif ${CONTAINER_DIRECTORY}/${tool_name}/${tool_version}/${tool_name}.sif
    # delete tmp files
    sudo rm -rf /tmp/${tool_name}/${tool_version}

done
