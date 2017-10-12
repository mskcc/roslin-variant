#!/bin/bash

# http://docs.aws.amazon.com/cli/latest/reference/ec2/attach-volume.html
# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html

instance_id="`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`"

# EBS for /ifs
aws ec2 attach-volume --volume-id vol-048c73b1300c8ef9c --instance-id ${instance_id} --device /dev/sdg

# just mount (as long as new volume already has the file system)
sudo mkdir -p /ifs
sudo mount /dev/xvdg /ifs
sudo chown ubuntu:ubuntu /ifs

# EBS for /scratch
aws ec2 attach-volume --volume-id ${volume_id} --instance-id ${instance_id} --device /dev/sdf

# just mount (as long as new volume already has the file system)
sudo mkdir -p /scratch
sudo mount /dev/xvdf /scratch
sudo chown ubuntu:ubuntu /scratch
