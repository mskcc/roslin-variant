#!/bin/bash -e

cd /tmp/
git clone https://github.com/mskcc/toil.git
cd toil

sudo python setup.py install --prefix /usr/local
sudo pip install toil[cwl,aws,mesos]
# pip install --install-option="--prefix=/usr/local"  toil[cwl]
