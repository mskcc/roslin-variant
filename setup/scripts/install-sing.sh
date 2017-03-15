#!/bin/bash

VERSION='1.0.0'

# load config
source ./settings.sh

cp ../bin/sing/sing-${VERSION}.sh ${PRISM_BIN_PATH}/bin/sing/sing.sh
cp ../bin/sing/sing-java-${VERSION}.sh ${PRISM_BIN_PATH}/bin/sing/sing-java.sh

# fixme: use symlink
# cp sing.sh ${PRISM_BIN_PATH}/bin/sing/sing-1.0.0.sh
# ln -snf ${PRISM_BIN_PATH}/bin/sing/sing-1.0.0.sh ${PRISM_BIN_PATH}/bin/sing/sing.sh

if [ "$PRISM_SYSTEM_WIDE_INSTALL" == "YES" ]
then
    echo "PATH=\$PATH:${PRISM_BIN_PATH}/bin/sing" | sudo tee /etc/profile.d/sing.sh
else
    echo "PATH=\$PATH:${PRISM_BIN_PATH}/bin/sing" | tee ~/.prism/sing.sh
fi
