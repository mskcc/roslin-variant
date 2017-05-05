#!/bin/bash -e

DOCKER_ENGINE_VERSION="1.13.1-0~ubuntu-xenial"

sudo apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://apt.dockerproject.org/gpg | sudo apt-key add -

apt-key fingerprint 58118E89F3A912897C070ADBF76221572C52609D

sudo add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       ubuntu-$(lsb_release -cs) \
       main"

sudo apt-get -y update

sudo apt-get -y install docker-engine=${DOCKER_ENGINE_VERSION}

sudo apt-cache madison docker-engine

