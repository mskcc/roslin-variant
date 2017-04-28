#!/bin/bash

version='$version.'

aws s3 cp s3://prism-installer/prism-v$version.tgz /tmp/
mkdir -p /tmp/prism-v$version/
tar xvzf /tmp/prism-v$version.tgz -C /tmp/prism-v$version/
cd /tmp/prism-v$version/setup/scripts/

sudo mkdir -p /ifs && sudo chmod a+w /ifs
./install-production.sh -l
./configure-reference-data.sh -l s3

cd /ifs/work/chunj/prism-proto/prism/bin/setup
sed -i "s|/usr/bin/singularity|/usr/local/bin/singularity|g" settings.sh
