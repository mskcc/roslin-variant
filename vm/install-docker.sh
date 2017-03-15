#!/bin/bash

DOCKER_ENGINE_VERSION="1.13.1-0~ubuntu-xenial"

apt-get install -y --no-install-recommends \
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

apt-get -y update

apt-get -y install docker-engine=${DOCKER_ENGINE_VERSION}

apt-cache madison docker-engine

