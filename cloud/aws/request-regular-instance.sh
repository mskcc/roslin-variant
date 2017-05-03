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

cat ${result_json}

# get instance id
instance_id=`jq -r .Instances[].InstanceId ${result_json}`

echo ${instance_id}

# wait till instance is in running state
aws ec2 wait instance-running --instance-ids ${instance_id}

# get public dns name
public_dns_name=`aws ec2 describe-instances --instance-ids ${instance_id} | jq ".Reservations[0].Instances[0].PublicDnsName"`

echo ${public_dns_name}

sleep 30

ssh -i ~/mskcc-chunj.pem -o "StrictHostKeyChecking no" ubuntu@${public_dns_name} "cat /var/log/prism-software-versions.txt"
# ssh -i "~/mskcc-chunj.pem" ${public_dns_name} "tail /var/log/cloud-init-output.log"

# delete temporary
rm -rf ${result_json}
