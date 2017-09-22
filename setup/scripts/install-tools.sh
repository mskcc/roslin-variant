#!/bin/bash -e

# load config
source ./settings.sh

cp -R ../tools/* ${ROSLIN_PIPELINE_BIN_PATH}/tools/

cd ${ROSLIN_PIPELINE_BIN_PATH}/tools/
md5sum -c checksum.dat
