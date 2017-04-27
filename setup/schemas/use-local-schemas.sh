#!/bin/bash

# load config
source ./settings.sh

root_dir="${PRISM_BIN_PATH}/pipeline/"
for file in `find ${root_dir} -name "*.cwl"`
do

    # make backup 
    cp ${file} ${file}.bak

    # replace http: to file: (already fetched in /schemas directory)
    cat ${file}.bak | \
        sed "s|- http://dublincore.org/2012/06/14/dcterms.rdf|- file://${PRISM_BIN_PATH}/schemas/dcterms.rdf|g" | \
        sed "s|- http://xmlns.com/foaf/spec/20140114.rdf|- file://${PRISM_BIN_PATH}/schemas/foaf.rdf|g" | \
        sed "s|- http://usefulinc.com/ns/doap#|- file://${PRISM_BIN_PATH}/schemas/doap.rdf|g" \
        > ${file}

    # get the number of line differences
    diff_count=`diff -y --suppress-common-lines ${file} ${file}.bak | grep '^' | wc -l`

    # the number of line differences must be either
    # 3: we replaced three lines
    # 0: if you ran this script more than once
    if [ $diff_count -ne 0 ] && [ $diff_count -ne 3 ]
    then
        echo $diff_count
        echo "Something is not right! Aborted!"
        exit 1
    fi

done
