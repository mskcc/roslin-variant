#!/bin/bash

usage()
{
cat << EOF

USAGE: `basename $0` [options]

OPTIONS:

   -v      pipeline name/version
   -u      Username you want to configure a workplace for
   -f      Overwrite workspace even if it exists

EXAMPLE:

   `basename $0` -u chunj

EOF
}

use_single_machine_example=0
force_overwrite=0

while getopts “v:u:sfh” OPTION
do
    case $OPTION in
        v) pipeline_name_version=$OPTARG ;;
        u) user_id=$OPTARG ;;
        s) use_single_machine_example=1 ;;
        f) force_overwrite=1 ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z "$pipeline_name_version" ]
then
    echo "Pipeline name/version must be set."
    exit 1
fi

if [ ! -r "${ROSLIN_CORE_CONFIG_PATH}/${pipeline_name_version}/settings.sh" ]
then
    echo "Can't find/read the specified Pipeline name/version."
    echo "${ROSLIN_CORE_CONFIG_PATH}/${pipeline_name_version}/settings.sh"
    exit 1
fi

# load pipeline settings
source ${ROSLIN_CORE_CONFIG_PATH}/${pipeline_name_version}/settings.sh

if [ -z $user_id ]
then
    usage
    exit 1
fi

if [ `whoami` != "$user_id" ]
then
    echo "You can only run this from your own account (`whoami` != ${user_id})"
    echo "Aborted."
    exit 1
fi

if [ -d "${ROSLIN_INPUT_PATH}/${user_id}" ] && [ "${force_overwrite}" -eq 0 ]
then
    echo "Your workspace already exists: ${ROSLIN_INPUT_PATH}/${user_id}"
    echo "Aborted."
    exit 1
fi

# create user directory
mkdir -p ${ROSLIN_INPUT_PATH}/${user_id}

# copy jumpstart examples
tar xzf ${ROSLIN_BIN_PATH}/examples.tgz -C ${ROSLIN_INPUT_PATH}/${user_id} --strip-components 1

if [ "$use_single_machine_example" -eq 1 ]
then
    find ${ROSLIN_INPUT_PATH}/${user_id}/ -name "run-example.sh" | xargs -I {} sed -i "s/lsf/singleMachine/g" {}
fi

echo "Your workspace: ${ROSLIN_INPUT_PATH}/${user_id}"
echo
