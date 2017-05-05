#!/bin/bash -e

SINGULARITY_VERSION="2.2.1"
SINGULARITY_INSTALL_TEMP_DIR="/tmp/singularity"

sudo apt-get -y install build-essential autoconf automake libtool debootstrap

mkdir -p ${SINGULARITY_INSTALL_TEMP_DIR} && cd $_

wget --no-check-certificate --content-disposition https://github.com/singularityware/singularity/releases/download/${SINGULARITY_VERSION}/singularity-${SINGULARITY_VERSION}.tar.gz
tar xvzf singularity-${SINGULARITY_VERSION}.tar.gz
rm -rf singularity-${SINGULARITY_VERSION}.tar.gz
cd singularity-${SINGULARITY_VERSION}
./configure --prefix=/usr/local
make
sudo make install

rm -rf ${SINGULARITY_INSTALL_TEMP_DIR}
