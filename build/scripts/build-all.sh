#!/bin/bash -e

# build container images
./build-images.sh

# build cwl wrappers
./build-cwl.sh

# check bind points
./test-bind-points.sh

if [ $? -eq 0 ]
then
    # push to docker hub
    ./push-to-docker-hub.sh
else
    echo "Bind points are not properly built into the container images."
    exit 1
fi
