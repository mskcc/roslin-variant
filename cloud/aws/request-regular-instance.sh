#!/bin/bash

aws ec2 run-instances \
  --cli-input-json file://specification.t2micro.json \
  --user-data file://install.sh
