#!/bin/bash -e

ARCHIVES_PATH="./archives"
OUTPUTS_PATH="./outputs"
STDOUT_LOG="${OUTPUTS_PATH}/stdout.log"

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
JOB_IDS=`grep -o -P "Got the job id: \d+" ${STDOUT_LOG} | awk -F':' '{ print $2 }' | uniq`

# get job id, name, final status, resources requeted and/or used
# https://www.ibm.com/support/knowledgecenter/en/SSETD4_9.1.2/lsf_command_ref/bjobs.1.html
bjobs -o 'jobid stat job_name max_mem avg_mem memlimit max_req_proc delimiter=","' ${JOB_IDS} > ${OUTPUTS_PATH}/bjobs.csv

if [ -x "$(command -v csvlook)" ]
then
  csvlook --no-inference ${OUTPUTS_PATH}/bjobs.csv
else
  cat ${OUTPUTS_PATH}/bjobs.csv
fi

# save the result of each job
for id in ${JOB_IDS}
do
  bjobs -l $id &> ${OUTPUTS_PATH}/lsf-job-$id.log
done
echo

# get job uuid
job_uuid=`sed -n '2{p;q;}' ${STDOUT_LOG} | awk -F'=' '{ print $2 }' | sed 's/ //g'`
printf "Job UUID : $job_uuid\n"

# get toil stats
toil stats $PRISM_BIN_PATH/tmp/jobstore-${job_uuid} > ${OUTPUTS_PATH}/toil-stats.log 2>&1

# get workflow id
workflow_id=`grep -m 1 -P -o "The workflow ID is: '(.*?)'" ${OUTPUTS_PATH}/${job_uuid}.log | awk -F':' '{ print $2 }' | sed "s/[' ]//g"`
printf "Workflow ID : $workflow_id\n"

# save file contents
python tree.py -f ${OUTPUTS_PATH} > ${OUTPUTS_PATH}/tree.outputs.txt
python tree.py -f $PRISM_BIN_PATH/tmp/jobstore-${job_uuid} > ${OUTPUTS_PATH}/tree.jobstore.txt
python tree.py -f $PRISM_BIN_PATH/tmp/toil-${workflow_id} > ${OUTPUTS_PATH}/tree.toiltmp.txt

ls -lh ${OUTPUTS_PATH}/* >> ${OUTPUTS_PATH}/tree.outputs.txt

# backup everything
new_archive_path=$(get_archive_name $ARCHIVES_PATH/$job_uuid)
mkdir -p ${new_archive_path}

tar czf ${new_archive_path}/outputs.tgz ${OUTPUTS_PATH}/*
tar czf ${new_archive_path}/jobstore.tgz -C $PRISM_BIN_PATH/tmp/ ./jobstore-${job_uuid}
tar czf ${new_archive_path}/toiltmp.tgz -C $PRISM_BIN_PATH/tmp/ ./toil-${workflow_id}

ls -l ${new_archive_path}
