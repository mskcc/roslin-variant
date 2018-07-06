#!/bin/bash

# install python
apt-get install -y python

# install pip
apt-get install -y python-pip
pip install --upgrade pip==9.0.3

# install nose (for unit testing)
pip install nose
