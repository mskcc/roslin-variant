#!/bin/bash

######################################
## RUN THIS FROM INSIDE VAGRANT BOX
######################################

# load build-related settings
source ./settings-build.sh

# load utils
source ./tools-utils.sh

output_root_dir="/vagrant/setup/cwl"

mkdir -p ${output_root_dir}

python move-cwl.py ${CWL_WRAPPER_DIRECTORY} ${output_root_dir}

# copy roslin_resources.json
cp ${CWL_WRAPPER_DIRECTORY}/roslin_resources.json ${output_root_dir}

# show tree
tree ${output_root_dir}

# get md5 checksum for all image files
cd ${output_root_dir}
find . -name "*.cwl" -type f | xargs md5sum > ${output_root_dir}/checksum.dat
