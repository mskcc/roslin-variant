#!/bin/bash

# required for pysam/htslib introduced in 1.7.0
# https://github.com/mskcc/cmo/commit/7eaefac72f45606ac1cfa8caeb1a0a47fef9695d
sudo apt-get install -y build-essential zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev

# required to do cwl postprocess
sudo -H pip install pyyaml ruamel.yaml

DEST_PATH="/usr/local/bin/"

#---------------------------------
# install cmo

# get cmo from git
sudo git clone https://github.com/mskcc/cmo.git ${DEST_PATH}/cmo-gxargparse/cmo
sudo chown -R vagrant:vagrant ${DEST_PATH}/cmo-gxargparse/cmo

# install dependencies
sudo -H pip install --upgrade pip==9.0.3

# install
cd ${DEST_PATH}/cmo-gxargparse/cmo
python setup.py develop --user

#---------------------------------
# install gxargparse

# get gxargparse from git
sudo git clone https://github.com/common-workflow-language/gxargparse.git ${DEST_PATH}/cmo-gxargparse/gxargparse
sudo chown -R vagrant:vagrant ${DEST_PATH}/cmo-gxargparse/gxargparse

# install dependencies
sudo -H pip install future
sudo apt-get install -y python-lxml

# install
cd ${DEST_PATH}/cmo-gxargparse/gxargparse
python setup.py install --user
