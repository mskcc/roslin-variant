#!/bin/bash -e

cd /tmp/
git clone https://github.com/mskcc/toil.git

cd toil
git checkout 3.8.2msk

sudo python setup.py install --prefix /usr/local
sudo pip install toil[cwl,aws,mesos]
# pip install --install-option="--prefix=/usr/local"  toil[cwl]
