#!/bin/bash

# AWS user data scripts are executed as the root user
# so do not use the sudo command in the script.

ROSLIN_CORE_VERSION="1.0.0"
ROSLIN_PIPELINE_NAME="variant"
ROSLIN_PIPELINE_VERSION="1.0.0"

s3_bucket="s3://roslin-installer"

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

# load the Roslin Core settings
source /tmp/roslin/core-${ROSLIN_CORE_VERSION}/config/settings.sh

# copy pipline from s3 to ec2
aws s3 cp ${s3_bucket}/roslin-${ROSLIN_PIPELINE_NAME}-pipeline-v${ROSLIN_PIPELINE_VERSION}.tgz ${ROSLIN_CORE_BIN_PATH}/install/

# install Roslin Pipeline
cd ${ROSLIN_CORE_BIN_PATH}/install
./install-pipeline.sh \
    -p roslin-${ROSLIN_PIPELINE_NAME}-pipeline-v${ROSLIN_PIPELINE_VERSION}.tgz

# initialize workspace
cd ${ROSLIN_CORE_BIN_PATH}
./roslin-workspace-init.sh \
    -v ${ROSLIN_PIPELINE_NAME}/${ROSLIN_PIPELINE_VERSION} \
    -u ubuntu \
    -s


roslin_pipeline_settings="${ROSLIN_CORE_CONFIG_PATH}/${ROSLIN_PIPELINE_NAME}/${ROSLIN_PIPELINE_VERSION}/settings.sh"
cp ${roslin_pipeline_settings} ${roslin_pipeline_settings}.bak

cat ${roslin_pipeline_settings}.bak | \
    sed 's|export ROSLIN_CMO_BIN_PATH=".*"|export ROSLIN_CMO_BIN_PATH="/usr/local/bin"|g' | \
    sed 's|export ROSLIN_CMO_PYTHON_PATH=".*"|export ROSLIN_CMO_PYTHON_PATH="/usr/local/lib/python2.7/dist-packages"|g' \
    > ${roslin_pipeline_settings}

# load the Roslin Pipeline settings
source ${ROSLIN_CORE_CONFIG_PATH}/${ROSLIN_PIPELINE_NAME}/${ROSLIN_PIPELINE_VERSION}/settings.sh

# install cmo
# libs required by cmo
apt-get install -y zlib1g-dev libbz2-dev liblzma-dev
cd /tmp
wget -O cmo-${ROSLIN_CMO_VERSION}.tar.gz https://github.com/mskcc/cmo/archive/${ROSLIN_CMO_VERSION}.tar.gz
tar xvzf cmo-${ROSLIN_CMO_VERSION}.tar.gz
cd cmo-${ROSLIN_CMO_VERSION}
PYTHONPATH="${ROSLIN_CMO_PYTHON_PATH}"
python setup.py install --prefix `dirname ${ROSLIN_CMO_BIN_PATH}`

#--> fixme #hack

# reduce resource requirements (for dev using t2.micro)
for file in `find ${ROSLIN_PIPELINE_BIN_PATH}/cwl -name "*.cwl"`
do
	sudo sed -i.bak "s/ramMin: .*/ramMin: 1/g" $file
	sudo sed -i.bak "s/coresMin: .*/coresMin: 1/g" $file
done

#<--

cp ./cmo/data/cmo_resources.json /usr/local/bin/

rm -rf /tmp/cmo-*

# give the ownership of the workspace and scratch to the 'ubuntu' user
chown -R ubuntu ${ROSLIN_PIPELINE_WORKSPACE_PATH}
chown -R ubuntu /scratch

# update .profile
# 
echo "source ${ROSLIN_CORE_CONFIG_PATH}/settings.sh" >> /home/ubuntu/.profile
echo "export PATH=${ROSLIN_CORE_BIN_PATH}:\$PATH" >> /home/ubuntu/.profile
echo "ulimit -s 65536"  >> /home/ubuntu/.profile



#
#fixme: copy references
#

# clean up
rm -rf /tmp/roslin
