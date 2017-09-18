#!/bin/bash

# load settings
source ./config/settings.sh

tar cvzf roslin-core-v${ROSLIN_CORE_VERSION}.tgz bin config schemas
