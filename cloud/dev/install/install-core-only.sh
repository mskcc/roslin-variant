#!/bin/bash

if [ `whoami` != "root" ]
then
  echo "sudo su first"
  exit 1
fi

# AWS user data scripts are executed as the root user
# so do not use the sudo command in the script.

ROSLIN_CORE_VERSION="1.0.0"

s3_bucket="s3://roslin-installer-dev/setup"

# permission
mkdir -p /ifs && chmod a+w /ifs

mkdir -p /tmp/roslin/

# copy Roslin Core from s3 to ec2
aws s3 cp ${s3_bucket}/roslin-core-v${ROSLIN_CORE_VERSION}.tgz /tmp/roslin/

# uncompress
mkdir -p /tmp/roslin/core-${ROSLIN_CORE_VERSION}/
tar xvzf /tmp/roslin/roslin-core-v${ROSLIN_CORE_VERSION}.tgz -C /tmp/roslin/core-${ROSLIN_CORE_VERSION}/

# install Roslin Core
cd /tmp/roslin/core-${ROSLIN_CORE_VERSION}/bin/install
./install-core.sh
