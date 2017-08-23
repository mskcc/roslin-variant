#!/bin/bash

if [ ! -x "$(command -v bjobs)" ]
then
  echo "bjobs not found. Aborted.".
  exit 1
fi

outputs_path="./outputs"

usage()
{
cat << EOF

USAGE: `basename $0` [options]

OPTIONS:

   -o      Job output directory

EOF
}

while getopts “o:” OPTION
do
    case $OPTION in
        o) outputs_path=$OPTARG ;;
        *) usage; exit 1 ;;
    esac
done

cwltoil_log="${outputs_path}/log/cwltoil.log"

if [ ! -d $outputs_path ] || [ ! -e $cwltoil_log ]
then
  echo "Unable to find ${cwltoil_log}"
  exit 1
fi

# get LSF job ids
job_ids=`grep -o -P "Got the job id: \d+" ${cwltoil_log} | awk -F':' '{ print $2 }' | uniq`

if [ -z "$job_ids" ]
then
  proj_name=`cat ${outputs_path}/job-uuid`
  proj_name=`bjobs -a -o proj_name | grep ${proj_name} | sort | uniq`
  job_ids=`bjobs -P "${proj_name}" -a -o jobid -noheader`
  if [ -z "$job_ids" ]
  then
    echo "No jobs found."
    exit 1
  fi
fi

# get job id, name, final status, resources requeted and/or used
# https://www.ibm.com/support/knowledgecenter/en/SSETD4_9.1.2/lsf_command_ref/bjobs.1.html
csv=`bjobs -o 'jobid stat job_name max_mem memlimit exec_host delimiter=","' ${job_ids}`

if [ -x "$(command -v tabulate)" ]
then
  echo "$csv" | tabulate --sep , -1 --format orgtbl
elif [ -x "$(command -v csvlook)" ]
then
  echo "$csv" | csvlook --no-inference
else
  echo "$csv" | column -s, -t
fi
