#!/bin/bash

HOME_TEMP=$HOME
export HOME=$ROSLIN_PIPELINE_RESOURCE_PATH
export NVM_DIR="$ROSLIN_PIPELINE_RESOURCE_PATH/.nvm"
# Setup node
mkdir $ROSLIN_PIPELINE_RESOURCE_PATH/.nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
source $ROSLIN_PIPELINE_RESOURCE_PATH/.nvm/nvm.sh
nvm install v12.4.0
export HOME=$HOME_TEMP