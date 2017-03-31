#!/bin/bash

# install bats
git clone https://github.com/sstephenson/bats.git ./helpers/bats
cd bats
./install.sh /usr/local

# install stub
git clone https://github.com/jimeh/stub.sh.git ./helpers/stub
