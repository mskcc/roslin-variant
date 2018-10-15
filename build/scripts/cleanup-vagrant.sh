#!/bin/bash

sudo find /var/tmp/* -name "docker-tar*"  -exec rm {} \;
sudo find /tmp/* -depth -not -name "vagrant-shell" -not -path '*/\.*' -exec rm -r {} \;