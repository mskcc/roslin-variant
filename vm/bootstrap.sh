#!/bin/bash

apt-get -y update

apt-get -y install tree jq

# required to do cwl postprocess
pip install pyyaml ruamel.yaml
