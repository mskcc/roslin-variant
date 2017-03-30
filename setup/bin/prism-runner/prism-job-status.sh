#!/bin/bash

if [ ! -x "$(command -v bjobs)" ]
then
  echo "No bjobs found. Aborted.".
  exit 1
fi

OUTPUTS_PATH="./outputs"

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
        o) OUTPUTS_PATH=$OPTARG ;;
        *) usage; exit 1 ;;
    esac
done

CWLTOIL_LOG="${OUTPUTS_PATH}/log/cwltoil.log"

if [ ! -d $OUTPUTS_PATH ] || [ ! -e $CWLTOIL_LOG ]
then
  echo "Unable to find ${CWLTOIL_LOG}"
  exit 1
fi

# get LSF job ids
JOB_IDS=`grep -o -P "Got the job id: \d+" ${CWLTOIL_LOG} | awk -F':' '{ print $2 }' | uniq`

if [ -z "$JOB_IDS" ]
then
  echo "No jobs found."
  exit 1
fi

# get job id, name, final status, resources requeted and/or used
# https://www.ibm.com/support/knowledgecenter/en/SSETD4_9.1.2/lsf_command_ref/bjobs.1.html
csv=`bjobs -o 'jobid stat job_name max_mem avg_mem memlimit max_req_proc exec_host delimiter=","' ${JOB_IDS}`

if [ -x "$(command -v tabulate)" ]
then
  echo "$csv" | tabulate --sep , -1 --format orgtbl
elif [ -x "$(command -v csvlook)" ]
then
  echo "$csv" | csvlook --no-inference
else
  echo "$csv" | column -s, -t
fi
