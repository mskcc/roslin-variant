#!/bin/bash

usage()
{
cat << EOF

USAGE: `basename $0` [options]

OPTIONS:

   -g      Group name (e.g. Group_12)

EOF
}


while getopts “g:” OPTION
do
    case $OPTION in
        g) group_name=$OPTARG ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z "${group_name}" ]
then
    usage
    exit 1
fi


project_name="Proj_DMPVAL_01a"

path_request="./${project_name}_request.txt"
path_mapping="./${project_name}_sample_mapping.txt"
path_grouping="./${project_name}_sample_grouping.txt"
path_pairing="./${project_name}_sample_pairing.txt"

grep -P "${group_name}$" ${project_name}_sample_grouping.original.txt > ${path_grouping}

# create inputs.yaml
./prism_request_to_yaml.py \
    -m ${path_mapping} \
    -p ${path_pairing} \
    -g ${path_grouping} \
    -r ${path_request} \
    -o ./outputs \
    -f ./inputs.yaml
