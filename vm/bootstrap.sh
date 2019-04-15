#!/usr/bin/env bash

# Update package manager and install the minimal packages needed to test Roslin
sudo yum -y update

# Set environment variables that roslin needs to find tools/data
source ${HOME}/.bashrc
echo -e "\nexport PATH=/opt/common/CentOS_6-dev/bin/current:/opt/common/CentOS_6-dev/python/python-2.7.10/bin:$PATH" >> ${HOME}/.bashrc
echo -e "\n[ -z "$BASH_VERSION" ] && exec /bin/bash -l" >> ${HOME}/.profile
