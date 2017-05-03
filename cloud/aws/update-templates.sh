#!/bin/bash

usage()
{
cat << EOF

USAGE: `basename $0` [options]

OPTIONS:

   -a      New AMI ID
   -s      New EBS Snapshot ID

EOF
}

while getopts “a:s:” OPTION
do
    case $OPTION in
        a) ami_id=$OPTARG ;;
        s) ebs_snapshot_id=$OPTARG ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z "$ami_id" ] || [ -z "$ebs_snapshot_id" ]
then
    usage
    exit 1
fi

# $1 filename
change()
{
    cp $1 $1.bak
    cat $1.bak | jq ".ImageId = \"${ami_id}\" | .BlockDeviceMappings[0].Ebs.SnapshotId = \"${ebs_snapshot_id}\"" > $1
    rm -rf $1.bak
}

change specification.template.json
change specification.t2micro.json

echo "Done."