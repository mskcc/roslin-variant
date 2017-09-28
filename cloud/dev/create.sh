#!/bin/bash

export AWS_PROFILE=prism
# export AWS_PROFILE=chunj

read -r -d '' scripts << EOM
../packer/scripts/bootstrap.sh
../packer/scripts/install-python.sh
../packer/scripts/install-singularity.sh
../packer/scripts/install-docker.sh
../packer/scripts/install-cwltoil-mskcc.sh
../packer/scripts/install-nodejs.sh
../packer/scripts/install-awscli.sh
../packer/scripts/check-versions.sh
./add-volume.sh
./misc.sh
EOM

rm -rf user-data.sh

for file in $scripts
do
  cat $file >> user-data.sh
  cat ./empty-lines.sh >> user-data.sh
done

result_json=`mktemp -q -t ec2-instance-result`

if [ $? -ne 0 ]
then
  echo "$0: Can't create temp file, exiting..."
  exit 1
fi

# create instance and save resulting json to ${result_json}
aws ec2 run-instances \
  --cli-input-json file://specification.${AWS_PROFILE}.json \
  --user-data file://user-data.sh | tee ${result_json}

# get instance id
instance_id=`jq -r .Instances[].InstanceId ${result_json}`

echo ${instance_id}

# add tags
aws ec2 create-tags \
    --resources ${instance_id} \
    --tags Key=Name,Value=roslin-pipeline-test Key=Owner,Value=chunj Key=lab,Value=prism

# wait till instance is in running state
aws ec2 wait instance-running --instance-ids ${instance_id}

# get public dns name
public_dns_name=`aws ec2 describe-instances --instance-ids ${instance_id} | jq -r ".Reservations[0].Instances[0].PublicDnsName"`

echo ${public_dns_name}

sleep 10

# poll every 5 sec if cloud-init is finished
while true
do
  ssh -i ~/${AWS_PROFILE}.pem -o "StrictHostKeyChecking no" ubuntu@${public_dns_name} "test -f /var/lib/cloud/instances/${instance_id}/boot-finished"
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
