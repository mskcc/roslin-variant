#!/bin/bash

VERSION='1.0.0'

# load config
source ./settings.sh

# copy scripts
cp ../bin/prism-runner/prism-runner.sh ${PRISM_BIN_PATH}/bin/prism-runner/prism-runner.sh
cp ../bin/prism-runner/roslin-job-archive.sh ${PRISM_BIN_PATH}/bin/prism-runner/roslin-job-archive.sh
cp ../bin/prism-runner/roslin-job-status.sh ${PRISM_BIN_PATH}/bin/prism-runner/roslin-job-status.sh
cp ../bin/prism-runner/tree.py ${PRISM_BIN_PATH}/bin/prism-runner/tree.py
cp ../bin/prism-runner/roslin-get-tmp-size.sh ${PRISM_BIN_PATH}/bin/roslin-get-tmp-size.sh

cp ../bin/prism-runner/roslin_submit.py ${PRISM_BIN_PATH}/bin/prism-runner/roslin_submit.py
cp ../bin/prism-runner/prism_runprofile.py ${PRISM_BIN_PATH}/bin/prism-runner/prism_runprofile.py
cp ../bin/prism-runner/prism_cacher.py ${PRISM_BIN_PATH}/bin/prism-runner/prism_cacher.py

cp ../bin/prism-runner/roslin_request_to_yaml.py ${PRISM_BIN_PATH}/bin/prism-runner/roslin_request_to_yaml.py
cp ../bin/prism-runner/roslin-project-status.sh ${PRISM_BIN_PATH}/bin/prism-runner/roslin-project-status.sh
cp ../bin/prism-runner/roslin-project-status.sh ${PRISM_BIN_PATH}/bin/prism-runner/bjp

if [ "$PRISM_SYSTEM_WIDE_INSTALL" == "YES" ]
then
    echo "PATH=\$PATH:${PRISM_BIN_PATH}/bin/prism-runner" | sudo tee /etc/profile.d/prism-runner.sh
fi
