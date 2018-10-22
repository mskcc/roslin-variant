#!/bin/bash

sudo find /var/tmp/ -name "docker-tar*"  -exec rm {} \;
sudo find /tmp/ -depth -not -name "vagrant-shell" -not -path '*/\.*' -exec rm -r {} \;
if [ ! -d /var/tmp/ ]
then
	sudo mkdir /var/tmp
	sudo chmod 1777 /var/tmp
fi
if [ ! -d /tmp/ ]
then
	sudo mkdir /tmp
	sudo chmod 1777 /tmp
fi
