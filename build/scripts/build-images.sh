#!/bin/bash -e

script_rel_dir=`dirname ${BASH_SOURCE[0]}`
script_dir=`python3 -c "import os; print(os.path.abspath('${script_rel_dir}'))"`

# load build-related settings
source $script_dir/settings-build.sh
source $SETUP_DIRECTORY/config/build-settings.sh

# load utils
source $script_dir/tools-utils.sh

unset XDG_RUNTIME_DIR

function finish {
    # clean up
    rm -rf $TMP_DIRECTORY
}
trap finish INT TERM EXIT

# by default, we will utilize docker cache to build images, which runs faster
BUILD_NO_CACHE="false"
DOCKER_REPO_TOOLNAME_PREFIX="roslin-variant"

usage()
{
cat << EOF

USAGE: $0 [options]

OPTIONS:

   -t      List of tools to build (comma-separated list)
           All pre-defined tools will be built if -t is not specified.

           Example: $0 -t bwa:0.7.5a,picard:2.9

   -d      Build docker images

   -s      Build singularity images

   -r      Docker registry name
           Example: "mskcc" for dockerhub or "localhost:5000" for local registry

   -p      Push to docker registry

   -z      Show list of tools that be built

   -n      No cache: images will be built from scratch

   -h      Print help

EOF
}

while getopts “t:dsr:pznh” OPTION
do
    case $OPTION in
        t) SELECTED_TOOLS_TO_BUILD=$OPTARG ;;
        d) BUILD_DOCKER_IMAGE="1" ;;
        s) BUILD_SINGULARITY_IMAGE="1" ;;
        r) DOCKER_REGISTRY_NAME=$OPTARG ;;
        p) PUSH_TO_DOCKER_REGISTRY="1" ;;
        z) for tool in $(get_tools_name_version); do echo $tool; done; exit 1 ;;
        n) BUILD_NO_CACHE="true" ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

if [ "$PUSH_TO_DOCKER_REGISTRY" == "1" ]
then
    if [ -z "$DOCKER_REGISTRY_NAME" ]
    then
        echo "Please specify the -r parameter when using the -p flag"
    else
        if [[ $DOCKER_REGISTRY_NAME != *"localhost"* ]]
        then
            BUILD_NO_CACHE="true"
        fi
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

    # don't build if tool name starts with @
    if [ ${tool_name:0:1} == "@" ]
    then
        continue
    fi

    echo "Building: ${tool_name} (version ${tool_version})"
    if [ -n "$DOCKER_REGISTRY_NAME" ]
    then
        docker_image_registry="${DOCKER_REGISTRY_NAME}/${DOCKER_REPO_TOOLNAME_PREFIX}-${tool_info}"
        docker_image_registry_url="docker://${docker_image_registry}"
    fi
    if [ "$BUILD_DOCKER_IMAGE" == "1" ]
    then
        if [ -n "$DOCKER_REGISTRY_NAME" ]
        then
            if [[ $DOCKER_REGISTRY_NAME != *"localhost"* ]]
            then
                if [ "$PUSH_TO_DOCKER_REGISTRY" != "1" ]
                then
                    docker_pull="1"
                    echo "Pulling from Docker Registry: ${docker_image_registry}"
                    docker pull ${docker_image_registry}
                    docker tag ${docker_image_registry} ${tool_info}
                fi
            fi
        fi

        if [ "$docker_pull" != "1" ]
        then
            echo "Building Docker Image locally"
            # add --quiet to make it less verbose
            if [ "$BUILD_NO_CACHE" == "false" ]
            then
                docker build -t ${tool_info} ${CONTAINER_DIRECTORY}/${tool_name}/${tool_version}
            else
                docker build --no-cache -t ${tool_info} ${CONTAINER_DIRECTORY}/${tool_name}/${tool_version}
            fi
        fi

        rm -rf $TMP_DIRECTORY/${tool_name}/${tool_version}
        mkdir -p $TMP_DIRECTORY/${tool_name}/${tool_version}

        if [ "$PUSH_TO_DOCKER_REGISTRY" == "1" ]
        then
            echo "Pushing to Docker Registry: ${docker_image_registry}"
            docker tag ${tool_info} ${docker_image_registry}
            docker push ${docker_image_registry}
        fi
    fi

    if [ "$BUILD_SINGULARITY_IMAGE" == "1" ]
    then
        echo "Building Singularity Image"
        if [[ $DOCKER_REGISTRY_NAME == *"localhost"* ]]
        then
            export SINGULARITY_NOHTTPS="y"
        fi

        if [ -z "$docker_image_registry" ]
        then
            docker_image_name=$tool_info
            export SINGULARITY_NOHTTPS="y"
        else
            docker_image_name=$docker_image_registry
        fi

        echo "Using Docker image: ${docker_image_name}"
        image_tmp=${TMP_DIRECTORY}/${tool_name}/${tool_version}
        export SINGULARITY_TMPDIR=$TMP_DIRECTORY
        export SINGULARITY_CACHEDIR=$TMP_DIRECTORY
        image_path=${CONTAINER_DIRECTORY}/${tool_name}/${tool_version}/${tool_name}.sif
        cache_path=${BUILD_CACHE}/${tool_name}/${tool_version}/${tool_name}.sif
        mkdir -p $image_tmp
        # retrieve labels from docker image and save to labels.json
        python3 $script_dir/docker-inspect.py --docker_image $docker_image_name --output $image_tmp
        md5sum ${CONTAINER_DIRECTORY}/${tool_name}/${tool_version}/runscript.sh >> ${image_tmp}/checksum.dat
        md5sum ${CONTAINER_DIRECTORY}/${tool_name}/${tool_version}/run_test.sh >> ${image_tmp}/checksum.dat
        cat ${image_tmp}/checksum.dat | awk -F" " '{print $1}' > ${image_tmp}/checksum.dat

        if [ -f $cache_path ]
        then
            currentDir=$(pwd)
            cd $image_tmp
            cp $cache_path .
            singularity exec ${tool_name}.sif sh -c "cat /dockerId.json 2>/dev/null || true" > singularityDockerId.json
            singularity exec ${tool_name}.sif sh -c "cat /checksum.dat 2>/dev/null || true" > singularityChecksum.dat
            cat singularityChecksum.dat | awk -F" " '{print $1}' > singularityChecksum.dat
            rm ${tool_name}.sif
            cd $currentDir
            dockerIdPath=$image_tmp/dockerId.json
            currentChecksum=$image_tmp/checksum.dat
            previousChecksum=$image_tmp/singularityChecksum.dat
            singularitydockerIdPath=$image_tmp/singularityDockerId.json
            dockerId=$(cat $singularitydockerIdPath)
            if cmp -s "$dockerIdPath" "$singularitydockerIdPath" && [ "$BUILD_NO_CACHE" == "false" ]
            then
                if cmp -s "$previousChecksum" "$currentChecksum"
                then
                    echo "Using cached singularity image: ${dockerId}"
                    /bin/cp -l $cache_path $image_path > /dev/null 2>&1 || /bin/cp $cache_path $image_path
                    continue
                else
                    if [ -w $cache_path ]
                    then
                        /bin/rm $cache_path
                    fi
                fi
            else
                if [ -w $cache_path ]
                then
                    /bin/rm $cache_path
                fi
            fi
        fi

        run_script=`cat ${CONTAINER_DIRECTORY}/${tool_name}/${tool_version}/runscript.sh`
        test_script_original=`cat ${CONTAINER_DIRECTORY}/${tool_name}/${tool_version}/run_test.sh`
        test_script=${test_script_original//"exec /usr/bin/runscript.sh"/"exec /.singularity.d/runscript"}
        # bootstrap the image
        if [ -n "$docker_image_registry" ]
        then
            image_url=docker://$docker_image_registry
        else
            image_url=docker-daemon://$tool_info
        fi

        singularity build --sandbox --force \
        $TMP_DIRECTORY/${tool_name}/${tool_version}/${tool_name} \
        $image_url

        mv $image_tmp/checksum.dat $image_tmp/${tool_name}/checksum.dat
        mv $image_tmp/labels.json $image_tmp/${tool_name}/labels.json
        mv $image_tmp/dockerId.json $image_tmp/${tool_name}/dockerId.json
        mv $image_tmp/dockerMeta.json $image_tmp/${tool_name}/dockerMeta.json

        # compress the image and build in non-shared directory
        # mmap does not like images being built on a shared directory

        singularity build --force $image_tmp/${tool_name}.sif $image_tmp/${tool_name}
        mv $image_tmp/${tool_name}.sif $image_path

        # run test
        singularity exec $image_path /run_test.sh

        if [ ! -f $cache_path ]
        then
            echo "Adding image: ${dockerId} to singularity cache"
            mkdir -p ${BUILD_CACHE}/${tool_name}/${tool_version}
            cp $image_path $cache_path
        fi

        # delete tmp files
        rm -rf $TMP_DIRECTORY
    fi
done
