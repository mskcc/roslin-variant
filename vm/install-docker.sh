#!/bin/bash

DOCKER_CE_VERSION="18.03.1~ce-0~ubuntu"

apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

apt-key fingerprint 58118E89F3A912897C070ADBF76221572C52609D

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get -y update

apt-get -y install docker-ce=${DOCKER_CE_VERSION}

apt-cache madison docker-ce