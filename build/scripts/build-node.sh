#!/bin/bash

HOME_TEMP=$HOME
export HOME=$ROSLIN_PIPELINE_RESOURCE_PATH
export NVM_DIR="$ROSLIN_PIPELINE_RESOURCE_PATH/.nvm"
# Setup node
mkdir $ROSLIN_PIPELINE_RESOURCE_PATH/.nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
source $ROSLIN_PIPELINE_RESOURCE_PATH/.nvm/nvm.sh
nvm install node
export HOME=$HOME_TEMP