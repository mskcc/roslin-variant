#!/bin/bash

if [ ! -x "$(command -v bjobs)" ]
then
  echo "bjobs not found. Aborted.".
  exit 1
fi

archives_path="./archives"
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

# if exists, add suffix .1, .2, ...
get_archive_name()
{
  dir=$1
  if [ -d $dir ]
  then
    i=1
    while [ -d $dir.$i ]
    do
      let i++
    done
    dir=$dir.$i
  fi
  echo $dir
}

# get LSF job ids
job_ids=`grep -o -P "Got the job id: \d+" ${cwltoil_log} | awk -F':' '{ print $2 }' | uniq`

if [ -z "$job_ids" ]
then
  proj_name=`cat ${outputs_path}/job-uuid`
  proj_name=`bjobs -a -o proj_name | grep ${proj_name} | sort | uniq`
  job_ids=`bjobs -P "${proj_name}" -a -o jobid -noheader`
fi

if [ ! -z "$job_ids" ]
then
  # get job id, name, final status, resources requeted and/or used
  # https://www.ibm.com/support/knowledgecenter/en/SSETD4_9.1.2/lsf_command_ref/bjobs.1.html
  bjobs -o 'jobid stat job_name max_mem avg_mem memlimit max_req_proc exec_host delimiter=","' ${job_ids} > ${outputs_path}/bjobs.csv

  if [ -x "$(command -v tabulate)" ]
  then
    tabulate --sep , -1 --format orgtbl ${outputs_path}/bjobs.csv
  elif [ -x "$(command -v csvlook)" ]
  then
    csvlook --no-inference ${outputs_path}/bjobs.csv
  else
    column -s, -t < ${outputs_path}/bjobs.csv
  fi

  # save the result of each job
  for id in ${job_ids}
  do
    bjobs -l $id &> ${outputs_path}/lsf-job-$id.log
  done
fi

echo

# get job uuid
job_uuid=`cat ${outputs_path}/job-uuid`
printf "Job UUID       : $job_uuid\n"

# get job store uuid
job_store_uuid=`cat ${outputs_path}/job-store-uuid`
printf "Job Store UUID : $job_store_uuid\n"

# get workflow id (choose the last one if many)
workflow_id=`grep -m 1 -P -o "The workflow ID is: '(.*?)'" ${cwltoil_log} | tail -1 | awk -F':' '{ print $2 }' | sed "s/[' ]//g"`
printf "Workflow ID    : $workflow_id\n"

# get toil stats
toil stats ${PRISM_BIN_PATH}/tmp/jobstore-${job_store_uuid} > ${outputs_path}/toil-stats.log 2>&1

# save file contents
python ${PRISM_BIN_PATH}/bin/prism-runner/tree.py -f ${outputs_path} > ${outputs_path}/tree.outputs.txt
python ${PRISM_BIN_PATH}/bin/prism-runner/tree.py -f ${PRISM_BIN_PATH}/tmp/jobstore-${job_store_uuid} > ${outputs_path}/tree.jobstore.txt
python ${PRISM_BIN_PATH}/bin/prism-runner/tree.py -f ${PRISM_BIN_PATH}/tmp/toil-${workflow_id} > ${outputs_path}/tree.toiltmp.txt

ls -lh ${outputs_path}/* >> ${outputs_path}/tree.outputs.txt

# backup everything
new_archive_path=$(get_archive_name $archives_path/$job_uuid)
mkdir -p ${new_archive_path}

tar czf ${new_archive_path}/outputs.tgz ${outputs_path}/*
tar czf ${new_archive_path}/jobstore.tgz -C ${PRISM_BIN_PATH}/tmp/ ./jobstore-${job_store_uuid}
tar czf ${new_archive_path}/toiltmp.tgz -C ${PRISM_BIN_PATH}/tmp/ ./toil-${workflow_id}

echo "Archived         : ${new_archive_path}"
