#!/bin/bash

# export CMO_RESOURCE_CONFIG="/vagrant/build/cwl-wrappers/cmo_resources.json"

project_name="Proj_DMPVAL_01"

# create split grouping files
python ./split.py

for batch_id in {1..16}
do
    # create a directory that will hold
    # mapping/grouping/paring/request files, inputs.yaml, and run-example.sh
    dest_dir="./batch-${batch_id}"
    mkdir -p ${dest_dir}

    path_request="${dest_dir}/${project_name}_${batch_id}_request.txt"
    path_mapping="${dest_dir}/${project_name}_${batch_id}_sample_mapping.txt"
    path_grouping="${dest_dir}/${project_name}_${batch_id}_sample_grouping.txt"
    path_pairing="${dest_dir}/${project_name}_${batch_id}_sample_pairing.txt"
    path_runex="${dest_dir}/run-example.sh"

    # copy mapping/pairing/request file from the parent directory
    echo "Copying request/mapping/pairing files for batch-${batch_id}"
    cp ../${project_name}_request.txt ${path_request}
    cp ../${project_name}_sample_mapping.txt ${path_mapping}
    cp ../${project_name}_sample_pairing.txt ${path_pairing}

    # append batch id to ProjectID in the request file (e.g. Proj_DMPVAL_01_1)
    sed -i "s|ProjectID: ${project_name}|ProjectID: ${project_name}_${batch_id}|g" ${path_request}

    echo "Generating inputs.yaml for batch-${batch_id}"

    # create inputs.yaml
    ./roslin_request_to_yaml.py \
        -m ${path_mapping} \
        -p ${path_pairing} \
        -g ${path_grouping} \
        -r ${path_request} \
        -o ${dest_dir}/outputs \
        -f ${dest_dir}/inputs.yaml

    # generate run-example.sh and make executable
    echo "Generating run-example.sh"
    cat > ${path_runex} << EOF
#!/bin/bash

# nohup prism-runner.sh \\
# 	-w project-workflow.cwl \\
# 	-i inputs.yaml \\
# 	-b lsf &

roslin_submit.py \\
   --id Proj_DMPVAL_01_${batch_id} \\
   --path . \\
   --workflow project-workflow.cwl
EOF
    chmod +x ${path_runex}

done

echo "Verifying inputs.yaml for each batch"
nosetests ./test_inputs_yaml.py
