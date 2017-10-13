#!/bin/bash

aws s3 sync s3://roslin-installer-dev/resources /ifs/tmp
cd tmp

dir="`pwd`"

mkdir -p /ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/
mkdir -p /ifs/work/chunj/prism-proto/ifs/depot/resources/vep/v86/
mkdir -p /ifs/work/pi/resources/roslin_resources/targets/
mkdir -p /ifs/work/prism/chunj/test-data/ffpe/
mkdir -p /ifs/work/prism/chunj/test-data/ref/
mkdir -p /ifs/work/chunj/prism-proto/ifs/depot/assemblies
mkdir -p /ifs/work/pi/resources/facets

# normal bams
cp -r ./normal-bams/* /ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/

# vep 86
cp -r ./vep/86/* /ifs/work/chunj/prism-proto/ifs/depot/resources/vep/v86/
cd /ifs/work/chunj/prism-proto/ifs/depot/resources/vep/v86/
tar xvzf vep86.tgz
tar xvzf homo_sapiens.tgz
rm -rf vep86.tgz
rm -rf homo_sapiens.tgz
cd $dir

# targets
cp -r ./targets/* /ifs/work/pi/resources/roslin_resources/targets/

# ffpe
cp -r ./ffpe/* /ifs/work/prism/chunj/test-data/ffpe/

# dbSNP, ...
cp -r ./ref/* /ifs/work/prism/chunj/test-data/ref/
cd /ifs/work/prism/chunj/test-data/ref/
tar xvzf ref.tgz
rm -rf ref.tgz
cd $dir

# b37
cp -r ./b37/* /ifs/work/chunj/prism-proto/ifs/depot/assemblies/
cd /ifs/work/chunj/prism-proto/ifs/depot/assemblies
tar xvzf b37.tgz
rm -rf b37.tgz
cd $dir

# facets
cp -r ./facets/* /ifs/work/pi/resources/facets/

# clean up
rm -rf /ifs/tmp

