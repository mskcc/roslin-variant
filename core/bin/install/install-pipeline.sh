#!/bin/bash

# load Roslin Core settings
source ${ROSLIN_CORE_CONFIG_PATH}/settings.sh

usage()
{
cat << EOF

USAGE: `basename $0` [options]

OPTIONS:

   -p	   Roslin Pipeline deployable package (.tgz file)
   -f      Overwrite the existing installation
   -h      Help

EOF
}

# defaults
force_overwrite=0

while getopts "p:fh" OPTION
do
    case $OPTION in
        p) pipeline_package_path=$OPTARG ;;
        f) force_overwrite=1 ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z "${pipeline_package_path}" ]
then
    usage
    exit 1
fi

if [ ! -r "${pipeline_package_path}" ]
then
    echo "Unable to find or read '${pipeline_package_path}'"
    exit 1
fi

pipeline_package_filename=`basename ${pipeline_package_path}`

# temporary tgz extraction path
install_temp_path=`mktemp -d`

# extract
echo "Extracting - this may take a while..."
tar xzf ${pipeline_package_path} -C ${install_temp_path}

# load the Roslin Pipeline settings.sh found in tgz
source ${install_temp_path}/setup/config/settings.sh

if [ -d ${ROSLIN_CORE_CONFIG_PATH}/${ROSLIN_PIPELINE_NAME}/${ROSLIN_PIPELINE_VERSION} ]
then
    if [ $force_overwrite -eq 0 ]
    then
        echo "roslin-${ROSLIN_PIPELINE_NAME}-pipeline-${ROSLIN_PIPELINE_VERSION} already exists."
        echo "Use -f if you want to overwrite."
        exit 1
    fi
fi

# copy the Roslin Pipeline settings.sh to Roslin Core config directory
mkdir -p ${ROSLIN_CORE_CONFIG_PATH}/${ROSLIN_PIPELINE_NAME}/${ROSLIN_PIPELINE_VERSION}
cp ${install_temp_path}/setup/config/settings.sh ${ROSLIN_CORE_CONFIG_PATH}/${ROSLIN_PIPELINE_NAME}/${ROSLIN_PIPELINE_VERSION}

echo
echo "roslin-${ROSLIN_PIPELINE_NAME}-pipeline-${ROSLIN_PIPELINE_VERSION}"
echo

#--> create directories

# container images
mkdir -p ${ROSLIN_PIPELINE_BIN_PATH}/img

# cwl wrappers
mkdir -p ${ROSLIN_PIPELINE_BIN_PATH}/cwl

# toil tmp
mkdir -p ${ROSLIN_PIPELINE_BIN_PATH}/tmp

# data path (e.g. resources such as genome assemblies)
mkdir -p ${ROSLIN_PIPELINE_DATA_PATH}

# directories for pipeline inputs (e.g. workspace, examples)
mkdir -p ${ROSLIN_PIPELINE_WORKSPACE_PATH}

# create output directory
mkdir -p ${ROSLIN_PIPELINE_OUTPUT_PATH}

#<--

#--> permission

# group should have read/write/execute permission
chmod -R 775 ${ROSLIN_PIPELINE_BIN_PATH}/img
chmod -R 775 ${ROSLIN_PIPELINE_BIN_PATH}/cwl

# everyone should have read/write/execute permission
chmod 777 ${ROSLIN_PIPELINE_BIN_PATH}/tmp
chmod 777 ${ROSLIN_PIPELINE_WORKSPACE_PATH}
chmod 777 ${ROSLIN_PIPELINE_OUTPUT_PATH}

#<--

# copy container images
cp -R ${install_temp_path}/setup/img/* ${ROSLIN_PIPELINE_BIN_PATH}/img/

# check md5 checksum
cd ${ROSLIN_PIPELINE_BIN_PATH}/img
md5sum -c checksum.dat

# copy cwl wrappers
cp -R ${install_temp_path}/setup/cwl/* ${ROSLIN_PIPELINE_BIN_PATH}/cwl/

# check md5 checksum
cd ${ROSLIN_PIPELINE_BIN_PATH}/cwl
md5sum -c checksum.dat

#--> use pre-fetched local schemas instead of going over the Internet to fetch
for file in `find ${ROSLIN_PIPELINE_BIN_PATH}/cwl -name "*.cwl"`
do

    parent_dir=$(python -c "import os; print os.path.abspath(os.path.join('${file}', '..'))")
    basename=$(python -c "import os; print os.path.basename('${parent_dir}')")

    # skip if the write permission is not granted on the parent directory or dirname starts with "dev-"
    if [ ! -w $parent_dir ] || [ $basename == dev-* ]
    then
        continue
    fi

    # skip if the write permission is not granted
    # if [ ! -w "$file" ] || [ ! -w "$file.bak" ]
    # then
    #     continue
    # fi

    # make backup
    cp ${file} ${file}.bak

    # replace http: to file: (already fetched in Roslin Core /schemas directory)
    cat ${file}.bak | \
        sed "s|- http://dublincore.org/2012/06/14/dcterms.rdf|- file://${ROSLIN_CORE_SCHEMA_PATH}/dcterms.rdf|g" | \
        sed "s|- http://xmlns.com/foaf/spec/20140114.rdf|- file://${ROSLIN_CORE_SCHEMA_PATH}/foaf.rdf|g" | \
        sed "s|- http://usefulinc.com/ns/doap#|- file://${ROSLIN_CORE_SCHEMA_PATH}/doap.rdf|g" \
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
#<--

# copy jumpstart examples
tar cvzf ${ROSLIN_PIPELINE_WORKSPACE_PATH}/examples.tgz -C ${install_temp_path}/setup ./examples

# clean up
rm -rf ${install_temp_path}

echo "DONE."
