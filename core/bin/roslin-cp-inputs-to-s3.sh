#!/bin/bash

s3_bucket="s3://roslin-installer-dev/workspace/${USER}"

temp_path=`mktemp -d`

cur_dir="`pwd`"
proj_name="`basename ${cur_dir}`"
mapping_file="${proj_name}_sample_mapping.txt"
rows=`cat ${mapping_file}`

if [ -r "$mapping_file" ]
then
    echo "Must be run from inside a project directory where mapping/grouping/pairing/request file exist."
    exit 1
fi

cp ${mapping_file} ${temp_path}

while read row
do
    id1=`echo "$row" | cut -f2`
    id2=`echo "$row" | cut -f3`
    data_path=`echo "$row" | cut -f4`

    new_path="${id1}-${id2}"

    aws s3 sync ${data_path}/ ${s3_bucket}/${proj_name}/${new_path}/

    sed -i "s|${data_path}|./${new_path}|g" ${temp_path}/${mapping_file}

done < ${mapping_file}

aws s3 cp ${temp_path}/${mapping_file} ${s3_bucket}/${proj_name}/
aws s3 cp ${proj_name}_sample_grouping.txt ${s3_bucket}/${proj_name}/
aws s3 cp ${proj_name}_sample_pairing.txt ${s3_bucket}/${proj_name}/
aws s3 cp ${proj_name}_request.txt ${s3_bucket}/${proj_name}/
aws s3 cp run-example.sh ${s3_bucket}/${proj_name}/

rm -rf ${temp_path}
