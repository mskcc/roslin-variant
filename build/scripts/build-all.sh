#!/bin/bash -e

usage()
{
cat << EOF

USAGE: $0 [options]

OPTIONS:

   -p      Push to Docker Hub
   -h      Help

EOF
}

push_to_dockerhub='yes'

while getopts “ph” OPTION
do
    case $OPTION in
        p) push_to_dockerhub='yes' ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

# build container images
./build-images.sh
if [ $? -eq 1 ]
then
    echo "Failed to build images."
    exit 1
fi

# build cwl wrappers
./build-cwl.sh
if [ $? -eq 1 ]
then
    echo "Failed to build CWL wrappers."
    exit 1
fi

if [ "$push_to_dockerhub" = 'yes' ]
then
    # push to docker hub
    ./push-to-docker-hub.sh
fi

echo "Done."