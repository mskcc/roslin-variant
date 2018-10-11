#!/bin/bash

SINGULARITY_VERSION="v3.0.0"
SINGULARITY_INSTALL_TEMP_DIR="/tmp/singularity"

mkdir -p ${SINGULARITY_INSTALL_TEMP_DIR} && cd $_

# instal go
wget https://dl.google.com/go/go1.11.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.11.1.linux-amd64.tar.gz
export GOPATH=${SINGULARITY_INSTALL_TEMP_DIR}/go_dir
export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin
mkdir -p $GOPATH/src/github.com/sylabs

# install singularity
cd $GOPATH/src/github.com/sylabs
git clone https://github.com/sylabs/singularity.git
cd singularity
git checkout v3.0.0
go get -u github.com/golang/dep/cmd/dep
./mconfig
cd ./builddir
make
sudo make install

# install singularity client that allows to programatically control singularity
sudo pip install singularity

rm -rf ${SINGULARITY_INSTALL_TEMP_DIR}