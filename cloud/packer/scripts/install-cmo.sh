#!/bin/bash -e

VERSION="1.4.3"

cd /tmp

wget -O cmo-${VERSION}.tar.gz https://github.com/mskcc/cmo/archive/${VERSION}.tar.gz
tar xvzf cmo-${VERSION}.tar.gz

cd cmo-${VERSION}

sudo python setup.py install

sudo cp ./cmo/data/cmo_resources.json /usr/local/bin/

sudo rm -rf /tmp/cmo-*
