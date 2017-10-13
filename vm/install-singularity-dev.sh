#!/bin/bash

SINGULARITY_INSTALL_TEMP_DIR="/tmp/singularity"

sudo apt-get -y install build-essential autoconf automake libtool debootstrap

mkdir -p ${SINGULARITY_INSTALL_TEMP_DIR} && cd $_

git clone https://github.com/singularityware/singularity.git
cd singularity
git fetch
git checkout development
./autogen.sh
./configure --prefix=/usr/local --sysconfdir=/etc
make
make install

# install singularity client that allows to programatically control singularity
sudo pip install singularity

rm -rf ${SINGULARITY_INSTALL_TEMP_DIR}
