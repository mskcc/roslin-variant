#!/bin/bash

# install bats
git clone https://github.com/sstephenson/bats.git ./helpers/bats
cd ./helpers/bats
sudo ./install.sh /usr/local

git clone https://github.com/ztombol/bats-support.git ./helpers/bats-support
git clone https://github.com/ztombol/bats-assert.git ./helpers/bats-assert
git clone https://github.com/ztombol/bats-file.git ./helpers/bats-file
