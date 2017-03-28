#!/bin/bash

VERSION="1.0.0"

cd /tmp

wget -O cmo-${VERSION}.tar.gz https://github.com/mskcc/cmo/archive/${VERSION}.tar.gz
tar xvzf cmo-${VERSION}.tar.gz
# git clone https://github.com/mskcc/cmo.git cmo-${VERSION}

cd cmo-${VERSION}

sudo pip install python-daemon
sudo python setup.py install

# sudo cp /tmp/cmo/cmo/data/cmo_resources.json /usr/local/bin/

# echo "export CMO_RESOURCE_CONFIG=\"/usr/local/bin/cmo_resources.json\"" | sudo tee /etc/profile.d/cmo-env.sh
# sudo chmod +x /etc/profile.d/cmo-env.sh
