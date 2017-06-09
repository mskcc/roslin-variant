#!/bin/bash -e

run()
{
    tool_name=$1
    tool_version=$2
    tool_command=$3

    work_dir="${tool_name}-${tool_version}"
    rm -rf ${work_dir}
    cp -r ./template ${work_dir}
    cd ${work_dir}

    python ../materialize.py ${tool_name} ${tool_version} ${tool_command}

    docker_name="gxargparse-${tool_name}-${tool_version}"
    docker build . -t ${docker_name} -f Dockerfile
    docker run -it --rm -v $(pwd):/data ${docker_name}
    # docker rmi ${docker_name}

}

run \
    ngs-filters \
    1.1.4 \
    /usr/bin/ngs-filters/run_ngs-filters.py

