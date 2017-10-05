#!/bin/bash


# required to do cwl postprocess
pip install pyyaml ruamel.yaml

DEST_PATH="/usr/local/bin/"

#---------------------------------
# install cmo

# get cmo from git
git clone https://github.com/mskcc/cmo.git ${DEST_PATH}/cmo-gxargparse/cmo

# install dependencies
pip install --upgrade pip

# install
cd ${DEST_PATH}/cmo-gxargparse/cmo
python setup.py develop --user

#---------------------------------
# install gxargparse

# get gxargparse from git
git clone https://github.com/common-workflow-language/gxargparse.git ${DEST_PATH}/cmo-gxargparse/gxargparse

# install dependencies
pip install future

apt-get install -y python-lxml
apt-get install -y libbz2-dev
apt-get install -y liblzma-dev

# install
cd ${DEST_PATH}/cmo-gxargparse/gxargparse
python setup.py install --user
