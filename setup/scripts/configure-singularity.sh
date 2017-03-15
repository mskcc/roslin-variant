#!/bin/bash

# enable overlay
sed -i.bak 's/enable overlay = no/enable overlay = yes/g' /usr/local/etc/singularity/singularity.conf
