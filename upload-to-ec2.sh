#!/bin/bash

usage()
{
cat << EOF

USAGE: $0 [options]

OPTIONS:

   -k      AWS key location
   -h      AWS EC2 host

EXAMPLE:

$0 -k ~/mskcc-chunj.pem -h ec2-54-172-127-54.compute-1.amazonaws.com

EOF
}

while getopts “k:h:” OPTION
do
    case $OPTION in
        k) KEY_PATH=$OPTARG ;;
        h) EC2_HOST=$OPTARG ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z $KEY_PATH ] || [ -z $EC2_HOST ]
then
    usage
    exit 1
fi

scp -i "${KEY_PATH}" prism-v1.0.0.tgz ubuntu@${EC2_HOST}:/tmp/

