#!/bin/bash

result_json=`mktemp -q -t ec2-instance-result`

if [ $? -ne 0 ]
then
  echo "$0: Can't create temp file, exiting..."
  exit 1
fi

# create instance and save resulting json to ${result_json}
aws ec2 run-instances \
  --cli-input-json file://specification.t2micro.json \
  --user-data file://install.sh | tee ${result_json}

# aws ec2 run-instances \
#   --cli-input-json file://specification.t2micro.json | tee ${result_json}

cat ${result_json}

# get instance id
instance_id=`jq -r .Instances[].InstanceId ${result_json}`

echo ${instance_id}

# add tags
aws ec2 create-tags \
    --resources ${instance_id} \
    --tags Key=Name,Value=prism-pipeline-test Key=Owner,Value=chunj

# wait till instance is in running state
aws ec2 wait instance-running --instance-ids ${instance_id}

# get public dns name
public_dns_name=`aws ec2 describe-instances --instance-ids ${instance_id} | jq -r ".Reservations[0].Instances[0].PublicDnsName"`

echo ${public_dns_name}

sleep 10

# check installed software
ssh -i ~/mskcc-chunj.pem -o "StrictHostKeyChecking no" ubuntu@${public_dns_name} "cat /var/log/prism-software-versions.txt"

# poll every 5 sec if cloud-init is finished
while true
do
  ssh -i ~/mskcc-chunj.pem -o "StrictHostKeyChecking no" ubuntu@${public_dns_name} "test -f /var/lib/cloud/instances/${instance_id}/boot-finished"
  if [ $? -eq 0 ]
  then
    break
  fi
  echo "Waiting..."
  sleep 10
done

# delete temporary
rm -rf ${result_json}

echo "Done."
