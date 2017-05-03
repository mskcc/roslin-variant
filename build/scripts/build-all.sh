#!/bin/bash -e

usage()
{
cat << EOF

USAGE: $0 [options]

OPTIONS:

   -n      Do not push to Docker Hub
   -h      Help

EOF
}

push_to_dockerhub='yes'

while getopts “nh” OPTION
do
    case $OPTION in
        n) push_to_dockerhub='no' ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

# build container images
./build-images.sh

# build cwl wrappers
./build-cwl.sh

# check bind points
./test-bind-points.sh

if [ $? -eq 0 ]
then
    if [ "$push_to_dockerhub" = 'yes' ]
    then
        # push to docker hub
        ./push-to-docker-hub.sh
    fi
else
    echo "Bind points are not properly built into the container images."
    exit 1
fi

echo "Done."