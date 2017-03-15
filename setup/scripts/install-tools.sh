#!/bin/bash -e

# load config
source ./settings.sh

cp -R ../tools/* ${PRISM_BIN_PATH}/tools/

cd ${PRISM_BIN_PATH}/tools/
md5sum -c checksum.dat
