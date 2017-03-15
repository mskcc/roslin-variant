#!/bin/bash

cd /tmp
git clone --branch prism-pipeline-test --single-branch https://github.com/hisplan/cmo.git
cd cmo

sudo pip install python-daemon
sudo python setup.py install

# sudo cp /tmp/cmo/cmo/data/cmo_resources.json /usr/local/bin/

# echo "export CMO_RESOURCE_CONFIG=\"/usr/local/bin/cmo_resources.json\"" | sudo tee /etc/profile.d/cmo-env.sh
# sudo chmod +x /etc/profile.d/cmo-env.sh

echo "Log out and log back in to reflect environment changes!"
