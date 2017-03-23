#!/bin/bash

get_revision()
{
    let revision=`cat ./REVISION`
    let revision++
    echo $revision
}

MAJOR_MINOR_VERSION="1.0"
REVISION=$(get_revision)

#fixme: need to fix fabfile before uncommenting this
# OUTPUT_FILENAME="prism-v${MAJOR_MINOR_VERSION}.${REVISION}.tgz"
OUTPUT_FILENAME="prism-v${MAJOR_MINOR_VERSION}.0.tgz"

tar \
    --exclude .DS_Store \
    --exclude P-00*.fastq.gz \
    --exclude ./setup/data/assemblies \
    -cvzf ${OUTPUT_FILENAME} ./setup

if [ $? -eq 0 ]
then    
    echo "$REVISION" > ./REVISION
    echo "$MAJOR_MINOR_VERSION.$REVISION"
fi
