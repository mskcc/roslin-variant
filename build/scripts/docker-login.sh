#!/bin/bash
# check if user is logged in to Docker Hub.
# the following command returns auth token if user is authenticated
if test -f ~/.docker/config.json
then
    is_login=`cat ~/.docker/config.json |  python -c 'import sys, json; print len(json.load(sys.stdin)["auths"])'`
else
    is_login="0"
fi

if [ "$is_login" == "0" ]
then
    docker login
    if [ $? -ne 0 ]
    then
        echo "You must be logged in to Docker Hub. Please try again."
        exit 1
    fi
fi