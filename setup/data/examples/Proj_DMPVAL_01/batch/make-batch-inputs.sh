#!/bin/bash

for batch_id in {1..4}
do
    echo "Generating inputs.yaml for batch-${batch_id}"
    ./prism_request_to_yaml.py \
        -m ./batch-${batch_id}/Proj_DMPVAL_01_${batch_id}_sample_mapping.txt \
        -p ./batch-${batch_id}/Proj_DMPVAL_01_${batch_id}_sample_pairing.txt \
        -g ./batch-${batch_id}/Proj_DMPVAL_01_${batch_id}_sample_grouping.txt \
        -r ./batch-${batch_id}/Proj_DMPVAL_01_${batch_id}_request.txt \
        -o ./batch-${batch_id}/outputs \
        -f ./batch-${batch_id}/inputs.yaml
done

echo "Verifying inputs.yaml for each batch"
nosetests test_inputs_yaml.py
