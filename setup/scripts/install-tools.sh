#!/bin/bash -e

# load config
source ./settings.sh

cp -R ../tools/* ${ROSLIN_BIN_PATH}/tools/

cd ${ROSLIN_BIN_PATH}/tools/
md5sum -c checksum.dat
