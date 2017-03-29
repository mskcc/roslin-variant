#!/bin/bash

VERSION='1.0.0'

# load config
source ./settings.sh

cp ../bin/sing/sing.sh ${PRISM_BIN_PATH}/bin/sing/sing.sh
cp ../bin/sing/sing-java.sh ${PRISM_BIN_PATH}/bin/sing/sing-java.sh

if [ "$PRISM_SYSTEM_WIDE_INSTALL" == "YES" ]
then
    echo "PATH=\$PATH:${PRISM_BIN_PATH}/bin/sing" | sudo tee /etc/profile.d/sing.sh
fi
