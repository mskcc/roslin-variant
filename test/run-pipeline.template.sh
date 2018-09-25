#!/bin/bash

pipeline_name_version={{ pipeline_name }}/{{ pipeline_version }}

job_uuid=`python -c 'import uuid; print str(uuid.uuid1())'`
lsf_proj_name="Proj_DEV_0003:${job_uuid}"
job_name="leader:${lsf_proj_name}"
job_desc=${job_name}

echo "Roslin core config path: ${ROSLIN_CORE_CONFIG_PATH}"
source ${ROSLIN_CORE_CONFIG_PATH}/${pipeline_name_version}/settings.sh

work_base_dir=${ROSLIN_PIPELINE_OUTPUT_PATH}
work_dir=${work_base_dir}/`echo ${job_uuid} | cut -c1-8`/${job_uuid}

echo "Job Info: $job_desc"
echo "Working Directory: ${work_dir}"

roslin_request_to_yaml.py \
    --pipeline ${pipeline_name_version} \
    -m Proj_DEV_0003_sample_mapping.txt \
    -p Proj_DEV_0003_sample_pairing.txt \
    -g Proj_DEV_0003_sample_grouping.txt \
    -r Proj_DEV_0003_request.txt \
    -o . \
    -f inputs.yaml

# push project info to db
init_project.py \
    --pipeline ${pipeline_name_version} \
    --path . \
    --id Proj_DEV_0003 \
    --work-dir ${work_dir} \
    --job-uuid ${job_uuid}

bsub -q controlR \
    -P ${lsf_proj_name} \
    -J ${job_name} \
    -Jd ${job_desc} \
    -oo ${work_dir}/stdout.log \
    -eo ${work_dir}/stderr.log \
    ${ROSLIN_CORE_BIN_PATH}/run_pipeline.py \
        --id Proj_DEV_0003 \
        --job-uuid ${job_uuid} \
        --work-dir ${work_dir} \
        --batch-system singleMachine \
        --pipeline ${pipeline_name_version} \
        --input-yaml ${work_dir}/inputs.yaml
