#!/bin/bash

# create a temp file to store packer's stdout
result_file=`mktemp -q -t ami-result`

# exit if can't create
if [ $? -ne 0 ]
then
  echo "$0: Can't create temp file, exiting..."
  exit 1
fi

# run packer for aws provider only
# install mskcc version of cwltoil
# send stdout to ${result_file}
packer build \
    -only=amazon-ebs \
    -var 'cwltoil_version=mskcc' \
    prism-node.packer | tee ${result_file}

# exit if packer failed
if [ $? -ne 0 ]
then
    echo "Failed!"
    exit 1
fi

# get ami id
ami_id=`tail -1 ${result_file} | awk '{ print $2 }'`

echo "AMI ID: ${ami_id}"

# get ebs snapshot id
ebs_snapshot_id=`aws ec2 describe-images --image-ids ${ami_id} | jq -r .Images[].BlockDeviceMappings[0].Ebs.SnapshotId`

echo "EBS Snapshot ID: ${ebs_snapshot_id}"

# delete temp file
rm -rf ${result_file}
