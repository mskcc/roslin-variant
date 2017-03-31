#!/bin/bash

# create fake-tool singularity image
cd ./mock/bin/tools/fake-tool/1.0.0/
rm -rf fake-tool.img
sudo singularity create -s 15 fake-tool.img
sudo singularity bootstrap fake-tool.img fake-tool.def
