#!/bin/bash -e

ARCHIVES_PATH="./archives"
OUTPUTS_PATH="./outputs"
STDOUT_LOG="${OUTPUTS_PATH}/stdout.log"

# get LSF job ids
JOB_IDS=`grep -o -P "Got the job id: \d+" ${STDOUT_LOG} | awk -F':' '{ print $2 }' | uniq`

# get job id, name, final status
# https://www.ibm.com/support/knowledgecenter/en/SSETD4_9.1.2/lsf_command_ref/bjobs.1.html
bjobs -o 'jobid stat job_name delimiter=","' ${JOB_IDS} > ${OUTPUTS_PATH}/bjobs.csv

if [ -e ~/.local/bin/csvlook ]
then
  ~/.local/bin/csvlook ${OUTPUTS_PATH}/bjobs.csv
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
workflow_id=`grep -m 1 -P -o "The workflow ID is: '(.*?)'" ${STDOUT_LOG} | awk -F':' '{ print $2 }' | sed "s/[' ]//g"`
printf "Workflow ID : $workflow_id\n"

# save file contents
python tree.py -f ${OUTPUTS_PATH} > ${OUTPUTS_PATH}/tree.outputs.txt
python tree.py -f $PRISM_BIN_PATH/tmp/jobstore-${job_uuid} > ${OUTPUTS_PATH}/tree.jobstore.txt
python tree.py -f $PRISM_BIN_PATH/tmp/toil-${workflow_id} > ${OUTPUTS_PATH}/tree.toiltmp.txt

ls -lh ${OUTPUTS_PATH}/* >> ${OUTPUTS_PATH}/tree.outputs.txt

# backup everything
mkdir -p ${ARCHIVES_PATH}/${job_uuid}
tar czf ${ARCHIVES_PATH}/${job_uuid}/outputs.tgz ${OUTPUTS_PATH}/*
tar czf ${ARCHIVES_PATH}/${job_uuid}/jobstore.tgz -C $PRISM_BIN_PATH/tmp/ ./jobstore-${job_uuid}
tar czf ${ARCHIVES_PATH}/${job_uuid}/toiltmp.tgz -C $PRISM_BIN_PATH/tmp/ ./toil-${workflow_id}

