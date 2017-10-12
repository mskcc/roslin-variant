#!/bin/bash

VERSION='1.0.0'

# load config
source ./settings.sh

# copy scripts
cp ../bin/prism-runner/roslin-runner.sh ${ROSLIN_PIPELINE_BIN_PATH}/bin/prism-runner/roslin-runner.sh
cp ../bin/prism-runner/roslin-job-archive.sh ${ROSLIN_PIPELINE_BIN_PATH}/bin/prism-runner/roslin-job-archive.sh
cp ../bin/prism-runner/roslin-job-status.sh ${ROSLIN_PIPELINE_BIN_PATH}/bin/prism-runner/roslin-job-status.sh
cp ../bin/prism-runner/tree.py ${ROSLIN_PIPELINE_BIN_PATH}/bin/prism-runner/tree.py
cp ../bin/prism-runner/roslin-get-tmp-size.sh ${ROSLIN_PIPELINE_BIN_PATH}/bin/prism-runner/roslin-get-tmp-size.sh
cp ../bin/prism-runner/roslin-restart.sh ${ROSLIN_PIPELINE_BIN_PATH}/bin/prism-runner/roslin-restart.sh
cp ../bin/prism-runner/roslin-kill-project.sh ${ROSLIN_PIPELINE_BIN_PATH}/bin/prism-runner/roslin-kill-project.sh

cp ../bin/prism-runner/roslin_submit.py ${ROSLIN_PIPELINE_BIN_PATH}/bin/prism-runner/roslin_submit.py
cp ../bin/prism-runner/roslin_runprofile.py ${ROSLIN_PIPELINE_BIN_PATH}/bin/prism-runner/roslin_runprofile.py
cp ../bin/prism-runner/roslin_cacher.py ${ROSLIN_PIPELINE_BIN_PATH}/bin/prism-runner/roslin_cacher.py
cp ../bin/prism-runner/roslin_track.py ${ROSLIN_PIPELINE_BIN_PATH}/bin/prism-runner/roslin_track.py
cp ../bin/prism-runner/roslin_copy_outputs.py ${ROSLIN_PIPELINE_BIN_PATH}/bin/prism-runner/roslin_copy_outputs.py

cp ../bin/prism-runner/roslin_request_to_yaml.py ${ROSLIN_PIPELINE_BIN_PATH}/bin/prism-runner/roslin_request_to_yaml.py
cp ../bin/prism-runner/roslin-project-status.sh ${ROSLIN_PIPELINE_BIN_PATH}/bin/prism-runner/roslin-project-status.sh
cp ../bin/prism-runner/roslin-project-status.sh ${ROSLIN_PIPELINE_BIN_PATH}/bin/prism-runner/bjp

cp ../bin/prism-runner/hello-roslin ${ROSLIN_PIPELINE_BIN_PATH}/bin/prism-runner/hello-roslin

if [ "$ROSLIN_SYSTEM_WIDE_INSTALL" == "YES" ]
then
    echo "PATH=\$PATH:${ROSLIN_PIPELINE_BIN_PATH}/bin/prism-runner" | sudo tee /etc/profile.d/roslin-runner.sh
fi
