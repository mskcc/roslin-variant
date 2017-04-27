#!/bin/bash

VERSION="1.0.2"

cd /tmp

wget -O cmo-${VERSION}.tar.gz https://github.com/mskcc/cmo/archive/${VERSION}.tar.gz
tar xvzf cmo-${VERSION}.tar.gz
# git clone https://github.com/mskcc/cmo.git cmo-${VERSION}

cd cmo-${VERSION}

# hack
# echo "__version__ = '1.0'" > ./cmo/_version.py

sudo pip install python-daemon
sudo python setup.py install
