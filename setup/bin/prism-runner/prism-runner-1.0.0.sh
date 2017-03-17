#!/bin/bash

if [ -z $PRISM_BIN_PATH ] || [ -z $PRISM_DATA_PATH ] || \
   [ -z $PRISM_INPUT_PATH ] || [ -z $PRISM_SINGULARITY_PATH ]
then
    echo "Some necessary paths are not correctly configured."
    echo "PRISM_BIN_PATH=${PRISM_BIN_PATH}"
    echo "PRISM_DATA_PATH=${PRISM_DATA_PATH}"
    echo "PRISM_INPUT_PATH=${PRISM_INPUT_PATH}"
    echo "PRISM_SINGULARITY_PATH=${PRISM_SINGULARITY_PATH}"    
    exit 1
fi


PIPELINE_VERSION=${PRISM_VERSION}
DEBUG_OPTIONS=""
OUTPUT_DIRECTORY=${PRISM_INPUT_PATH}/chunj/outputs

usage()
{
cat << EOF

USAGE: `basename $0` [options]

Prism Pipeline Runner

OPTIONS:

   -v      Pipeline version (default=${PIPELINE_VERSION})
   -w      Workflow filename (*.cwl)
   -i      Input filename (*.yaml)
   -o      Output directory (default=${OUTPUT_DIRECTORY})
   -d      Enable debugging

EXAMPLE:

   `basename $0` -v 1.0.0 -w module-1.cwl -i inputs-module-1.yaml
   `basename $0` -v test  -w cmo-bwa-mem.cwl -i inputs-cmo-bwa-mem.yaml

EOF
}


while getopts “v:w:i:o:d” OPTION
do
    case $OPTION in
        v) PIPELINE_VERSION=$OPTARG ;;
        w) WORKFLOW_FILENAME=$OPTARG ;;
        i) INPUT_FILENAME=$OPTARG ;;
        o) OUTPUT_DIRECTORY=$OPTARG ;;
        d) DEBUG_OPTIONS="--logDebug --cleanWorkDir never" ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z $WORKFLOW_FILENAME ] || [ -z $INPUT_FILENAME ]
then
    usage
    exit 1
fi

# override CMO_RESOURC_CONFIG only while cwltoil is running
export CMO_RESOURCE_CONFIG="${PRISM_BIN_PATH}/pipeline/${PRISM_VERSION}/prism_resources.json"

jobstore_uuid="jobstore-`python -c 'import uuid; print str(uuid.uuid1())'`"
jobstore_path="${PRISM_BIN_PATH}/tmp/${jobstore_uuid}"

printf "\n---> JOBSTORE = ${jobstore_uuid}\n"

# run cwltoil
cwltoil \
    ${PRISM_BIN_PATH}/pipeline/${PIPELINE_VERSION}/${WORKFLOW_FILENAME} \
    ${PRISM_INPUT_PATH}/chunj/${INPUT_FILENAME} \
    --jobStore file://${jobstore_path} \
    --defaultDisk 10G \
    --preserve-environment PATH PRISM_DATA_PATH PRISM_BIN_PATH PRISM_INPUT_PATH PRISM_SINGULARITY_PATH CMO_RESOURCE_CONFIG \
    --no-container \
    --disableCaching \
    --workDir ${PRISM_BIN_PATH}/tmp \
    --batchSystem lsf --stats \
    --outdir ${OUTPUT_DIRECTORY} ${DEBUG_OPTIONS}

# revert CMO_RESOURCE_CONFIG
unset CMO_RESOURCE_CONFIG

printf "\n<--- JOBSTORE = ${jobstore_uuid}\n\n"