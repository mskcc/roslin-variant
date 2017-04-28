#!/bin/bash

cat specification.json

if [ -z "$1" ]
then
    printf "\n\nSpecify spot price (e.g. 0.25)\n"
    exit 1
fi

# http://docs.aws.amazon.com/cli/latest/reference/ec2/request-spot-instances.html
aws ec2 request-spot-instances \
  --spot-price "$1" \
  --instance-count 1 \
  --type "one-time" \
  --launch-specification file://specification.json | tee result.json
