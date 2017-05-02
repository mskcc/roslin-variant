#!/bin/bash -e

# get spot request id
spot_req_id=`jq -r .SpotInstanceRequests[].SpotInstanceRequestId result.json`
echo "Spot Request ID: ${spot_req_id}"

# get ec2 instance id
instance_id=`aws ec2 describe-instances --filters "Name=spot-instance-request-id,Values=${spot_req_id}" | jq -r .Reservations[].Instances[].InstanceId`
echo "Instance ID: ${instance_id}"

# add tags
aws ec2 create-tags \
    --resources ${spot_req_id} ${instance_id} \
    --tags Key=Name,Value=prism-pipeline-test Key=Owner,Value=chunj

echo "Tagged."