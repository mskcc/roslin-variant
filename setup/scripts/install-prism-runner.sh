#!/bin/bash

VERSION='1.0.0'

# load config
source ./settings.sh

# copy scripts
cp ../bin/prism-runner/prism-runner.sh ${PRISM_BIN_PATH}/bin/prism-runner/prism-runner.sh
cp ../bin/prism-runner/prism-job-archive.sh ${PRISM_BIN_PATH}/bin/prism-runner/prism-job-archive.sh
cp ../bin/prism-runner/prism-job-status.sh ${PRISM_BIN_PATH}/bin/prism-runner/prism-job-status.sh
cp ../bin/prism-runner/tree.py ${PRISM_BIN_PATH}/bin/prism-runner/tree.py

cp ../bin/prism-runner/prism_submit.py ${PRISM_BIN_PATH}/bin/prism-runner/prism_submit.py
cp ../bin/prism-runner/prism_runprofile.py ${PRISM_BIN_PATH}/bin/prism-runner/prism_runprofile.py

if [ "$PRISM_SYSTEM_WIDE_INSTALL" == "YES" ]
then
    echo "PATH=\$PATH:${PRISM_BIN_PATH}/bin/prism-runner" | sudo tee /etc/profile.d/prism-runner.sh
fi
