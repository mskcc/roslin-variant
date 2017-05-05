#!/bin/bash -e

VERSION="1.0.5"

cd /tmp

wget -O cmo-${VERSION}.tar.gz https://github.com/mskcc/cmo/archive/${VERSION}.tar.gz
tar xvzf cmo-${VERSION}.tar.gz

cd cmo-${VERSION}

# sudo pip install python-daemon
sudo python setup.py install

sudo rm -rf /tmp/cmo-*
