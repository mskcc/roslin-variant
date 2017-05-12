#!/bin/bash

# remove tmp under prism bin
rm -rf ${PRISM_BIN_PATH}/tmp/*
# find ${PRISM_BIN_PATH}/tmp -maxdepth 1 -type d -name ! . -user chunj | xargs -I {} rm -rf {}

# remove tmp under the current
find ${PRISM_INPUT_PATH}/chunj -name tmp* | xargs -I {} rm -rf {}
