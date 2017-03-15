#!/bin/bash

# load config
source ./settings.sh

cp -R ../cwl-wrappers/* ${PRISM_BIN_PATH}/pipeline/

cd ${PRISM_BIN_PATH}/pipeline/${PRISM_VERSION}
md5sum -c checksum.dat
