#!/bin/bash

# if [ -z "$ROSLIN_CORE_VERSION" ] || [ -z "$ROSLIN_CORE_ROOT" ] || \
#    [ -z "$ROSLIN_CORE_PATH" ] || [ -z "$ROSLIN_CORE_BIN_PATH" ] || \
#    [ -z "$ROSLIN_CORE_CONFIG_PATH" ]
# then
#     echo "Some of the necessary paths are not correctly configured!"
#     echo "ROSLIN_CORE_VERSION=${ROSLIN_CORE_VERSION}"
#     echo "ROSLIN_CORE_ROOT=${ROSLIN_CORE_ROOT}"
#     echo "ROSLIN_CORE_PATH=${ROSLIN_CORE_PATH}"
#     echo "ROSLIN_CORE_BIN_PATH=${ROSLIN_CORE_BIN_PATH}"
#     echo "ROSLIN_CORE_CONFIG_PATH=${ROSLIN_CORE_CONFIG_PATH}"
#     exit 1
# fi

if [ -z "$ROSLIN_BIN_PATH" ] || [ -z "$ROSLIN_DATA_PATH" ] || \
   [ -z "$ROSLIN_INPUT_PATH" ] || [ -z "$ROSLIN_OUTPUT_PATH" ] || \
   [ -z "$ROSLIN_EXTRA_BIND_PATH" ] || [ -z "$ROSLIN_SINGULARITY_PATH" ] || \
   [ -z "$ROSLIN_CMO_VERSION" ] || [ -z "$ROSLIN_CMO_PYTHON_PATH" ]
then
    echo "Some of the necessary paths are not correctly configured!"
    echo "ROSLIN_BIN_PATH=${ROSLIN_BIN_PATH}"
    echo "ROSLIN_DATA_PATH=${ROSLIN_DATA_PATH}"
    echo "ROSLIN_EXTRA_BIND_PATH=${ROSLIN_EXTRA_BIND_PATH}"
    echo "ROSLIN_INPUT_PATH=${ROSLIN_INPUT_PATH}"
    echo "ROSLIN_OUTPUT_PATH=${ROSLIN_OUTPUT_PATH}"
    echo "ROSLIN_SINGULARITY_PATH=${ROSLIN_SINGULARITY_PATH}"
    echo "ROSLIN_CMO_VERSION=${ROSLIN_CMO_VERSION}"
    echo "ROSLIN_CMO_PYTHON_PATH=${ROSLIN_CMO_PYTHON_PATH}"
    exit 1
fi

# check Singularity existstence only if you're not on leader nodes
# fixme: this is so MSKCC-specific
leader_node=(luna selene)
case "${leader_node[@]}" in  *"`hostname -s`"*) leader_node='yes' ;; esac

if [ "$leader_node" != 'yes' ]
then
    if [ ! -x "`command -v $ROSLIN_SINGULARITY_PATH`" ]
    then
        echo "Unable to find Singularity."
        echo "ROSLIN_SINGULARITY_PATH=${ROSLIN_SINGULARITY_PATH}"
        exit 1
    fi
fi

# defaults
PIPELINE_NAME_VERSION=${ROSLIN_DEFAULT_PIPELINE_NAME_VERSION}

DEBUG_OPTIONS=""
RESTART_OPTIONS=""
RESTART_JOBSTORE_ID=""
BATCH_SYSTEM=""
OUTPUT_DIRECTORY="./outputs"

usage()
{
cat << EOF

USAGE: `basename $0` [options]

Prism Pipeline Runner

OPTIONS:

   -v      Pipeline name/version (default=${PIPELINE_NAME_VERSION})
   -w      Workflow filename (*.cwl)
   -i      Input filename (*.yaml)
   -b      Batch system ("singleMachine", "lsf", "mesos")
   -o      Output directory (default=${OUTPUT_DIRECTORY})
   -r      Restart the workflow with the given job store UUID
   -z      Show list of supported workflows
   -d      Enable debugging (default="enabled")
           fixme: you're not allowed to disable this right now

OPTIONS for MSKCC LSF+TOIL:

   -p      CMO Project ID (e.g. Proj_5088_B)
   -j      Pre-generated job UUID

EXAMPLE:

   `basename $0` -w module-1.cwl -i inputs-module-1.yaml -b lsf
   `basename $0` -w cmo-bwa-mem.cwl -i inputs-cmo-bwa-mem.yaml -b singleMachine

EOF
}


while getopts “v:w:i:b:o:r:zdp:j:” OPTION
do
    case $OPTION in
        v) PIPELINE_NAME_VERSION=$OPTARG ;;
        w) WORKFLOW_FILENAME=$OPTARG ;;
        i) INPUT_FILENAME=$OPTARG ;;
        b) BATCH_SYSTEM=$OPTARG ;;
        o) OUTPUT_DIRECTORY=$OPTARG ;;
        r) RESTART_JOBSTORE_ID=$OPTARG; RESTART_OPTIONS="--restart" ;;
       	z) cd ${ROSLIN_BIN_PATH}/cwl
           find . -name "*.cwl" -exec bash -c "echo {} | cut -c 3- | sort" \;
           exit 0
           ;;
        d) DEBUG_OPTIONS="--logDebug --cleanWorkDir never" ;;
        p) CMO_PROJECT_ID=$OPTARG ;;
        j) JOB_UUID=$OPTARG ;;
        *) usage; exit 1 ;;
    esac
done

if [ ! -d "$ROSLIN_CMO_PYTHON_PATH" ]
then
    echo "Can't find python package at $ROSLIN_CMO_PYTHON_PATH"
    exit 1
fi

if [ -z $WORKFLOW_FILENAME ] || [ -z $INPUT_FILENAME ]
then
    usage
    exit 1
fi

if [ ! -r "$INPUT_FILENAME" ]
then
    echo "The input file is not found or not readable."
    exit 1
fi

# handle batch system options
case $BATCH_SYSTEM in

    singleMachine)
        BATCH_SYS_OPTIONS="--batchSystem singleMachine"
        ;;

    lsf)
        BATCH_SYS_OPTIONS="--batchSystem lsf --stats"
        ;;

    mesos)
        echo "Unsupported right now."
        exit 1
        ;;

    *)
        usage
        exit 1
        ;;
esac


# get absolute path for output directory
OUTPUT_DIRECTORY=`python -c "import os;print(os.path.abspath('${OUTPUT_DIRECTORY}'))"`

# check if output directory already exists
if [ -d ${OUTPUT_DIRECTORY} ]
then
    echo "The specified output directory already exists: ${OUTPUT_DIRECTORY}"
    echo "Aborted."
    exit 1
fi

# create output directory
mkdir -p ${OUTPUT_DIRECTORY}

# create log directory (under output)
mkdir -p ${OUTPUT_DIRECTORY}/log

# override CMO_RESOURC_CONFIG only while cwltoil is running
export CMO_RESOURCE_CONFIG="${ROSLIN_BIN_PATH}/cwl/roslin_resources.json"

if [ -z "${JOB_UUID}" ]
then
    # create a new UUID for job
    job_uuid=`python -c 'import uuid; print str(uuid.uuid1())'`
else
    # use the supplied one
    job_uuid=${JOB_UUID}
fi

if [ -z "${CMO_PROJECT_ID}" ]
then
    cmo_project_id="default"
else
    cmo_project_id="${CMO_PROJECT_ID}"
fi

# MSKCC LSF+TOIL
export TOIL_LSF_PROJECT="${cmo_project_id}:${job_uuid}"

if [ -z "$RESTART_JOBSTORE_ID" ]
then
    # create a new UUID for job store
    job_store_uuid=`python -c 'import uuid; print str(uuid.uuid1())'`
else
    # we're doing a restart - use the supplied jobstore uuid
    job_store_uuid=${RESTART_JOBSTORE_ID}
fi

# save job uuid
echo "${job_uuid}" > ${OUTPUT_DIRECTORY}/job-uuid

# save jobstore uuid
echo "${job_store_uuid}" > ${OUTPUT_DIRECTORY}/job-store-uuid

jobstore_path="${ROSLIN_BIN_PATH}/tmp/jobstore-${job_store_uuid}"

# job uuid followed by a colon (:) and then job store uuid
printf "\n---> ROSLIN JOB UUID = ${job_uuid}:${job_store_uuid}\n"

echo "Using ${ROSLIN_CMO_VERSION} CMO package version"

# set PYTHONPATH
export PYTHONPATH="${ROSLIN_CMO_PYTHON_PATH}"

# assume if the python path is there, this will also be there
export PATH=/ifs/work/pi/cmo_package_archive/${ROSLIN_CMO_VERSION}/bin:$PATH

# run cwltoil
set -o pipefail
cwltoil \
    ${ROSLIN_BIN_PATH}/cwl/${WORKFLOW_FILENAME} \
    ${INPUT_FILENAME} \
    --jobStore file://${jobstore_path} \
    --defaultDisk 10G \
    --defaultMem 12G \
    --preserve-environment PATH PYTHONPATH ROSLIN_DATA_PATH ROSLIN_BIN_PATH ROSLIN_EXTRA_BIND_PATH ROSLIN_INPUT_PATH ROSLIN_OUTPUT_PATH ROSLIN_SINGULARITY_PATH CMO_RESOURCE_CONFIG \
    --no-container \
    --not-strict \
    --disableCaching \
    --realTimeLogging \
    --maxLogFileSize 0 \
    --writeLogs	${OUTPUT_DIRECTORY}/log \
    --logFile ${OUTPUT_DIRECTORY}/log/cwltoil.log \
    --workDir ${ROSLIN_BIN_PATH}/tmp \
    --outdir ${OUTPUT_DIRECTORY} ${RESTART_OPTIONS} ${BATCH_SYS_OPTIONS} ${DEBUG_OPTIONS} \
    | tee ${OUTPUT_DIRECTORY}/output-meta.json
exit_code=$?

# revert CMO_RESOURCE_CONFIG
unset CMO_RESOURCE_CONFIG

# revert TOIL_LSF_PROJECT
unset TOIL_LSF_PROJECT

printf "\n<--- ROSLIN JOB UUID = ${job_uuid}:${job_store_uuid}\n\n"

exit ${exit_code}
