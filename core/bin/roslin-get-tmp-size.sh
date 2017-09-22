#!/bin/bash

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

# get job uuid
job_uuid=`cat ${outputs_path}/job-uuid`
printf "Job UUID       : $job_uuid\n"

# get job store uuid
job_store_uuid=`cat ${outputs_path}/job-store-uuid`
printf "Job Store UUID : $job_store_uuid\n"

# get workflow id (choose the last one if many)
workflow_id=`grep -m 1 -P -o "The workflow ID is: '(.*?)'" ${cwltoil_log} | tail -1 | awk -F':' '{ print $2 }' | sed "s/[' ]//g"`
printf "Workflow ID    : $workflow_id\n"

# load the Roslin Pipeline settings used
source ${outputs_path}/settings

echo
echo "with all symbolic links dereferenced"
du ${outputs_path} -shL
du ${ROSLIN_PIPELINE_BIN_PATH}/tmp/jobstore-${job_store_uuid} -shL
du ${ROSLIN_PIPELINE_BIN_PATH}/tmp/toil-${workflow_id} -shL

echo
echo "without following any symbolic links"
du ${outputs_path} -sh
du ${ROSLIN_PIPELINE_BIN_PATH}/tmp/jobstore-${job_store_uuid} -sh
du ${ROSLIN_PIPELINE_BIN_PATH}/tmp/toil-${workflow_id} -sh
