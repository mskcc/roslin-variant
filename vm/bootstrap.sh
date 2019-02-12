#!/usr/bin/env bash

# Update package manager and install the minimal packages needed to test Roslin
sudo yum update -q -y
sudo yum install -y tree jq python-pip

# Set environment variables that roslin needs to find tools/data
source ${HOME}/.bashrc
if [ -z ${CMO_RESOURCE_CONFIG} ]; then
    echo -e "\nexport CMO_RESOURCE_CONFIG=/vagrant/setup/bin/roslin_resources.json" >> ${HOME}/.bashrc
fi
