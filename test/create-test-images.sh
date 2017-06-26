#!/bin/bash

# create fake-tool singularity image
cd ./mock/bin/tools/fake-tool/1.0.0/
rm -rf fake-tool.img
sudo singularity create -s 15 fake-tool.img
sudo singularity bootstrap fake-tool.img fake-tool.def

# back out
cd ../../../../..

# create env-tool singularity image
cd ./mock/bin/tools/env-tool/1.0.0/
rm -rf env-tool.img
sudo singularity create -s 15 env-tool.img
sudo singularity bootstrap env-tool.img env-tool.def
