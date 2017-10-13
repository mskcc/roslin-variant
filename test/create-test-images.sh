#!/bin/bash

start_dir=`pwd`

# create fake-tool singularity image
cd ./mock/roslin-pipelines/variant/1.0.0/bin/img/fake-tool/1.0.0/
rm -rf fake-tool.img
sudo singularity create -s 15 fake-tool.img
sudo singularity bootstrap fake-tool.img fake-tool.def

# back out
cd ${start_dir}

# create env-tool singularity image
cd ./mock/roslin-pipelines/variant/1.0.0/bin/img/env-tool/1.0.0/
rm -rf env-tool.img
sudo singularity create -s 15 env-tool.img
sudo singularity bootstrap env-tool.img env-tool.def
