#!/bin/bash -e

# load config
source ./settings.sh

# hack: local vm doesn't have enough ram/cores
find ${ROSLIN_PIPELINE_BIN_PATH}/pipeline/${ROSLIN_PIPELINE_VERSION} -name "*.cwl" | xargs -I {} sed -i.bak "s/ramMin: .*/ramMin: 5/g" {}
find ${ROSLIN_PIPELINE_BIN_PATH}/pipeline/${ROSLIN_PIPELINE_VERSION} -name "*.cwl" | xargs -I {} sed -i.bak "s/coresMin: .*/coresMin: 1/g" {}
