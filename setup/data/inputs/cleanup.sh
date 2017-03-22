#!/bin/bash

# remove tmp under prism bin
rm -rf ${PRISM_BIN_PATH}/tmp/*

# remove tmp under the current
find ${PRISM_INPUT_PATH}/chunj -name tmp* | xargs -I {} rm -rf {}