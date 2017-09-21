#!/bin/bash

# load settings
source ../../config/settings.sh

mkdir -p ${ROSLIN_CORE_PATH}
mkdir -p ${ROSLIN_CORE_BIN_PATH}
mkdir -p ${ROSLIN_CORE_CONFIG_PATH}
mkdir -p ${ROSLIN_CORE_SCHEMA_PATH}

# copy scripts
cp -r ../* ${ROSLIN_CORE_BIN_PATH}
cp -r ../../config/* ${ROSLIN_CORE_CONFIG_PATH}
cp -r ../../schemas/* ${ROSLIN_CORE_SCHEMA_PATH}
cp ${ROSLIN_CORE_BIN_PATH}/roslin-project-status.sh ${ROSLIN_CORE_BIN_PATH}/bjp

cat << "EOF"

 ______     ______     ______     __         __     __   __
/\  == \   /\  __ \   /\  ___\   /\ \       /\ \   /\ "-.\ \
\ \  __<   \ \ \/\ \  \ \___  \  \ \ \____  \ \ \  \ \ \-.  \
 \ \_\ \_\  \ \_____\  \/\_____\  \ \_____\  \ \_\  \ \_\\"\_\
  \/_/ /_/   \/_____/   \/_____/   \/_____/   \/_/   \/_/ \/_/

Add the following two lines to your .profile or .bashrc:

EOF

echo "source ${ROSLIN_CORE_CONFIG_PATH}/settings.sh"
echo "export PATH=\${ROSLIN_CORE_BIN_PATH}:\$PATH"
