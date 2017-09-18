#!/bin/bash

VERSION='1.0.0'

# load config
source ./settings.sh

cp ../bin/sing/sing.sh ${ROSLIN_BIN_PATH}/bin/sing/sing.sh
cp ../bin/sing/sing-java.sh ${ROSLIN_BIN_PATH}/bin/sing/sing-java.sh
cp ../bin/sing/sing-perl.sh ${ROSLIN_BIN_PATH}/bin/sing/sing-perl.sh

if [ "$ROSLIN_SYSTEM_WIDE_INSTALL" == "YES" ]
then
    echo "PATH=\$PATH:${ROSLIN_BIN_PATH}/bin/sing" | sudo tee /etc/profile.d/sing.sh
fi
