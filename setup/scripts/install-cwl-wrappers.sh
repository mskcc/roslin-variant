#!/bin/bash

# load config
source ./settings.sh

# copy cwl wrappers
cp -R ../cwl-wrappers/* ${PRISM_BIN_PATH}/pipeline/

# copy RDF schemas that are referenced by cwl wrappers
cp -R ../schemas/* ${PRISM_BIN_PATH}/schemas/

# check md5 checksum
cd ${PRISM_BIN_PATH}/pipeline/${PRISM_VERSION}
md5sum -c checksum.dat

# use pre-fetched local schemas instead of going over the Internet to fetch
${PRISM_BIN_PATH}/schemas/use-local-schemas.sh
