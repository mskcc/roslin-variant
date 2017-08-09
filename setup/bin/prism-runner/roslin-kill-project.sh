#!/bin/bash

usage()
{
cat << EOF

USAGE: `basename $0` [options]

OPTIONS:

   -p	   LSF project name (e.g. Proj_05583_F:d95fcae6-7c55-11e7-865e-645106efb11c)
   -l      LSF leader job ID

NOTES:

-l will be ignored if -p is specified, and vice versa.

EOF
}

while getopts "p:l:h" OPTION
do
    case $OPTION in
        p) lsf_project_name=$OPTARG ;;
        l) lsf_leader_job_id=$OPTARG ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

if [ ! -z ${lsf_leader_job_id} ]
then
    lsf_project_name=`bjobs -o proj_name -noheader ${lsf_leader_job_id}`
    if [[ "${lsf_project_name}" == *"not found"* ]]
    then
        echo "Unable to find the leader job"
        exit 1
    fi
fi

if [ -z	${lsf_project_name} ]
then
    usage
    exit 1
fi

list=`bjobs -P ${lsf_project_name} -o "jobid delimiter=','" -noheader 2>&1`

if [ "${list}" == "No unfinished job found" ]
then
    echo "No jobs found for '${lsf_project_name}'"
    exit 0
fi

for id in ${list}
do
    bkill $id
done
