#!/bin/bash

# install python
apt-get install -y python

# install pip
apt-get install -y python-pip==9.0.3
#pip install --upgrade pip

# install nose (for unit testing)
pip install nose
