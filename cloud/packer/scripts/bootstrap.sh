#!/bin/bash -e

sudo apt-get -y update

# install tree and jq
sudo apt-get -y install tree jq

# create /scratch directory
sudo mkdir -p /scratch
