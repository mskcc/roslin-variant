#!/bin/bash

usage()
{
cat << EOF

USAGE: `basename $0` [options]

OPTIONS:

   -u	   user id
   -p      project name
   -h      Help

EOF
}

# defaults
force_overwrite=0

while getopts "u:p:h" OPTION
do
    case $OPTION in
        u) user_id=$OPTARG ;;
        p) proj_name=$OPTARG ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z "$user_id" ] || [ -z "$proj_name" ]
then
    usage
    exit 1
fi

s3_bucket="s3://roslin-installer-dev/workspace/${user_id}/${proj_name}"

mkdir -p ${proj_name}
aws s3 sync ${s3_bucket} ${proj_name}

chmod +x ${proj_name}/run-example.sh

echo
echo "Make sure to update run-example.sh in ./${proj_name}/"
echo "- Ensure Roslin Pipeline name and version is the one that you wish to use."
echo "- roslin_submit.py is not supported."
echo "- LSF is not supported."
echo
