#!/bin/bash

VERSION='1.0.0'

# load config
source ./settings.sh

# fixme: use symlink
cp ../bin/prism-runner/prism-runner-${VERSION}.sh ${PRISM_BIN_PATH}/bin/prism-runner/prism-runner.sh
cp ../bin/prism-runner/prism-job-archive-${VERSION}.sh ${PRISM_BIN_PATH}/bin/prism-runner/prism-job-archive.sh
cp ../bin/prism-runner/prism-job-status-${VERSION}.sh ${PRISM_BIN_PATH}/bin/prism-runner/prism-job-status.sh
cp ../bin/prism-runner/tree.py ${PRISM_BIN_PATH}/bin/prism-runner/tree.py

if [ "$PRISM_SYSTEM_WIDE_INSTALL" == "YES" ]
then
    echo "PATH=\$PATH:${PRISM_BIN_PATH}/bin/prism-runner" | sudo tee /etc/profile.d/prism-runner.sh
fi
