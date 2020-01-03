#!/bin/bash

script_rel_dir=`dirname ${BASH_SOURCE[0]}`
script_dir=`python3 -c "import os; print(os.path.abspath('${script_rel_dir}'))"`
SETUP_DIRECTORY=`python3 -c "import os; print(os.path.abspath(os.path.join(os.path.dirname('${script_dir}'),os.path.pardir,'setup')))"`
BUILD_DIRECTORY=`python3 -c "import os; print(os.path.abspath(os.path.join(os.path.dirname('${script_dir}'),os.path.pardir,'build')))"`
TMP_DIRECTORY=`python3 -c "import tempfile; print(tempfile.mkdtemp())"`
# directory where Dockerfile, Singularity, and images are stored
CONTAINER_DIRECTORY="${BUILD_DIRECTORY}/containers"

CWL_DIRECTORY="${SETUP_DIRECTORY}/cwl"

IMG_DIRECTORY="${SETUP_DIRECTORY}/img"
