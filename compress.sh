#!/bin/bash

VERSION="1.0.0"
OUTPUT_FILENAME="prism-v${VERSION}.tgz"

tar \
    --exclude .DS_Store \
    --exclude P-00*.fastq.gz \
    --exclude ./setup/data/assemblies \
    -cvzf ${OUTPUT_FILENAME} ./setup

