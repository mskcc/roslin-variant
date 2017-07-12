#!/bin/bash

version='1.0.0'

aws s3 cp s3://roslin-installer/roslin-v$version.tgz /tmp/
mkdir -p /tmp/roslin-v$version/
tar xvzf /tmp/roslin-v$version.tgz -C /tmp/roslin-v$version/
cd /tmp/roslin-v$version/setup/scripts/

sudo mkdir -p /ifs && sudo chmod a+w /ifs
./install-production.sh -l
./configure-reference-data.sh -l s3

cd /ifs/work/chunj/prism-proto/prism/bin/setup
sed -i "s|/usr/bin/singularity|/usr/local/bin/singularity|g" settings.sh

# clean up
rm -rf /tmp/roslin-v$version.tgz
rm -rf /tmp/roslin-v$version
