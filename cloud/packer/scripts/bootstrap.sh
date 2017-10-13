#!/bin/bash -e

sudo apt-get -y update

# install utilities
sudo apt-get -y install tree jq

# create /scratch directory
sudo mkdir -p /scratch
