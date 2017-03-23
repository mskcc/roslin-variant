#!/bin/bash

OUTPUTS_PATH="./outputs"
STDOUT_LOG="${OUTPUTS_PATH}/stdout.log"

if [ ! -d $OUTPUTS_PATH ] || [ ! -e $STDOUT_LOG ]
then
  echo "No output found. Did you run the job?"
  exit 1
fi

# get LSF job ids
JOB_IDS=`grep -o -P "Got the job id: \d+" ${STDOUT_LOG} | awk -F':' '{ print $2 }' | uniq`

if [ -z $JOB_IDS ]
then
  echo "No jobs found"
  exit 1
fi

# get job id, name, final status, resources requeted and/or used
# https://www.ibm.com/support/knowledgecenter/en/SSETD4_9.1.2/lsf_command_ref/bjobs.1.html
csv=`bjobs -o 'jobid stat job_name max_mem avg_mem memlimit max_req_proc delimiter=","' ${JOB_IDS}`

if [ -x "$(command -v csvlook)" ]
then
  echo "$csv" | ~/.local/bin/csvlook --no-inference
else
  echo "$csv"
fi
