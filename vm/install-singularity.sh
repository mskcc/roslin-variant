#!/bin/bash

SINGULARITY_VERSION="2.5.1"
SINGULARITY_INSTALL_TEMP_DIR="/tmp/singularity"

mkdir -p ${SINGULARITY_INSTALL_TEMP_DIR} && cd $_

wget --no-check-certificate --content-disposition https://github.com/singularityware/singularity/releases/download/${SINGULARITY_VERSION}/singularity-${SINGULARITY_VERSION}.tar.gz
tar xvzf singularity-${SINGULARITY_VERSION}.tar.gz
rm -rf singularity-${SINGULARITY_VERSION}.tar.gz
cd singularity-${SINGULARITY_VERSION}
./autogen.sh
./configure --prefix=/usr/local
make
make install

# install singularity client that allows to programatically control singularity
sudo pip install singularity

rm -rf ${SINGULARITY_INSTALL_TEMP_DIR}

