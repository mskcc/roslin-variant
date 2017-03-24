#!/bin/bash

VERSION='1.0.0'

# load config
source ./settings.sh

# fixme: use symlink
cp ../bin/prism-runner/prism-runner-${VERSION}.sh ${PRISM_BIN_PATH}/bin/prism-runner/prism-runner.sh

if [ "$PRISM_SYSTEM_WIDE_INSTALL" == "YES" ]
then
    echo "PATH=\$PATH:${PRISM_BIN_PATH}/bin/prism-runner" | sudo tee /etc/profile.d/prism-runner.sh
fi
