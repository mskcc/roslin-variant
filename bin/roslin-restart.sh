#!/bin/bash

usage()
{
cat << EOF

USAGE: `basename $0` [options]

OPTIONS:

   -p	   LSF project name (e.g. Proj_05583_F:d95fcae6-7c55-11e7-865e-645106efb11c)
   -e      Not just show the restart command, but execute it as well
   -h      Help

EOF
}

while getopts "p:eh" OPTION
do
    case $OPTION in
        p) lsf_project_name=$OPTARG ;;
        e) execute='EXECUTE' ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z	${lsf_project_name} ]
then
    usage
    exit 1
fi

lsf_leader_job_name="leader:${lsf_project_name}"

job_store_uuid=`bjobs -J "${lsf_leader_job_name}" -a -u all -noheader -o "exec_cwd" | xargs -I {} cat {}/outputs/job-store-uuid`

project_dir=`bjobs -J "${lsf_leader_job_name}" -a -u all -noheader -o "sub_cwd"`

cmo_project_id=`grep "ProjectID:" ${project_dir}/*_request.txt | cut -c12-`

restart_cmd="roslin_submit.py --id ${cmo_project_id} --path ${project_dir} --workflow project-workflow.cwl --restart ${job_store_uuid}"

if [ "${execute}" = "EXECUTE" ]
then
    exec ${restart_cmd}
else
    echo "Here's the restart command that we can come up with."
    echo "Re-run with -e or execute the following command to restart the workflow."
    echo
    echo "${restart_cmd}"
    echo
fi
