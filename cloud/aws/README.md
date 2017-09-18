# Amazon Web Services

## One Time Setup

### Building AMI

Use Packer to build an AMI first. This is only required if you need to rebuild an image.

If you did recreate the AMI, capture the AMI ID generated and replace the old AMI ID in the `specification.template.json` file with the new AMI ID.

### Deploy Reference Files

tbd

### Deploy Setup Files

```
$ python compress.py
$ aws s3 cp roslin-v1.0.0.tgz s3://roslin-installer/
```

## Single Machine Test

Request a spot instance to save the cost. And depending on the type of the instance being launched, you can test different things.

### Instance Types

Here are some choices:

#### t2.micro (anywhere)

Only sufficient for checking the installation process, whether software is correctly installed and configured, and verifying cwltoil/singularity can run against a very tiny dataset. Can't run module 1 through 3 as a whole.

#### r4.2xlarge (us-east-1f):

Able to run module 1 and 2. Module 3 cannot be run due to parallelism, but individual steps in module 3 can run separately.

- 8 vCPU
- 61 GB RAM
- EBS-Only (no need to mount so easy to set up)
- Price (as of 2017-07-12)
    - $0.5320 per hour (on-demand)
    - Avg $0.06 per hour during business hours (spot; us-east-1f)

#### r4.8xlarge (us-east-1c)

Able to run module 1 through 3.

- 32 vCPU
- 244 GB RAM
- EBS-Only (no need to mount so easy to set up)
- Price (as of 2017-04-28)
    - $2.1280 per hour (on-demand)
    - Avg $0.37 per hour during business hours (spot; us-east-1c)

### Request Spot Instance

```bash
$ python make_specification.py --zone us-east-1c --instance-type r4.8xlarge --save
```

```bash
$ ./request-spot-instance.sh 0.40
```

Output would look something like below:

```json
{
    "SpotInstanceRequests": [
        {
            "Status": {
                "UpdateTime": "2017-04-28T18:07:54.000Z", 
                "Code": "pending-evaluation", 
                "Message": "Your Spot request has been submitted for review, and is pending evaluation."
            }, 
            "ProductDescription": "Linux/UNIX", 
            "SpotInstanceRequestId": "sir-nvjr5zik", 
            "State": "open", 
            "LaunchSpecification": {
                "Placement": {
                    "AvailabilityZone": "us-east-1c"
                }, 
                "ImageId": "ami-5bddba4d", 
                "KeyName": "mskcc-chunj", 
                "BlockDeviceMappings": [
                    {
                        "DeviceName": "/dev/sda1", 
                        "Ebs": {
                            "DeleteOnTermination": true, 
                            "SnapshotId": "snap-051b8e1a5ac3959cc", 
                            "VolumeSize": 60, 
                            "VolumeType": "gp2"
                        }
                    }
                ], 
                "SecurityGroups": [
                    {
                        "GroupName": "my-security-group-ssh", 
                        "GroupId": "sg-19c52d66"
                    }
                ], 
                "SubnetId": "subnet-d4fe67b1", 
                "Monitoring": {
                    "Enabled": false
                }, 
                "IamInstanceProfile": {
                    "Arn": "arn:aws:iam::273241104452:instance-profile/prism-node-role"
                }, 
                "InstanceType": "r4.8xlarge"
            }, 
            "Type": "one-time", 
            "CreateTime": "2017-04-28T18:07:54.000Z", 
            "SpotPrice": "0.400000"
        }
    ]
}
```

Optional: run the following to tag the instance. Note that this only works for a single instance. Also, you need `jq` installed on your machine to run this. Run this after a spot request has been approved.

```bash
$ ./tag.sh
```

### Installation

Prism installation automatically kicks in as the instance is being brought up. Though, the installation takes quite long right now because it needs to copy genome reference and other files from S3 (will start using EFS once MSKCC AWS account is set up). To check the status, ssh into the instance and run the following command:

```bash
$ tail -f /var/log/cloud-init-output.log
```

### Creating Workspace

SSH into the instance and run the `roslin-init.sh` command based on the instance you brought up:

### r4.2xlarge or higher

```bash
$ cd /ifs/work/chunj/prism-proto/prism/bin/setup
$ ./roslin-init.sh -u ubuntu -s
```

### t2.micro

```bash
$ cd /tmp/prism-v1.0.0/setup/scripts/
$ ./reduce-resources-requirements.sh
```

Log out and log back in.

See if you can run the sam2bam workflow:

```bash
$ cd $ROSLIN_INPUT_PATH/ubuntu/examples/samtools-sam2bam
$ ./run-example.sh
```

You are ready.

## Trouble Shooting

The versions of the major software installed can be found by:

```bash
$ cat prism-software-versions.txt
```
