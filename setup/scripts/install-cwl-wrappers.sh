#!/bin/bash -e

# load config
source ./settings.sh

# copy cwl wrappers
cp -R ../cwl-wrappers/* ${PRISM_BIN_PATH}/pipeline/

# copy RDF schemas that are referenced by cwl wrappers
cp -R ../schemas/* ${PRISM_BIN_PATH}/schemas/

# use pre-fetched local schemas instead of going over the Internet to fetch
root_dir="${PRISM_BIN_PATH}/pipeline/"
for file in `find ${root_dir} -name "*.cwl"`
do

    parent_dir=$(python -c "import os; print os.path.abspath(os.path.join('${file}', '..'))")
    basename=$(python -c "import os; print os.path.basename('${parent_dir}')")

    # skip if the write permission is not granted on the parent directory or dirname starts with "dev-"
    if [ ! -w $parent_dir ] || [ $basename == dev-* ]
    then
        continue
    fi

    # skip if the write permission is not granted
    if [ ! -w "$file" ] || [ ! -w "$file.bak" ]
    then
        continue
    fi

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

# check md5 checksum
cd ${PRISM_BIN_PATH}/pipeline/${PRISM_VERSION}
md5sum -c checksum.dat
