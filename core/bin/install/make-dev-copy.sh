#!/bin/bash

# load Roslin Core settings
source ../../config/settings.sh

usage()
{
cat << EOF

USAGE: `basename $0` [options]

OPTIONS:

   -p	   Roslin Pipeline deployable package (.tgz file)
   -s      Suffix to be added to the version string
           (e.g. the suffix 'abc' will create '1.0.0-dev-chunj-abc')
   -h      Help

EOF
}

# defaults
suffix=''

while getopts "p:s:h" OPTION
do
    case $OPTION in
        p) pipeline_package_path=$OPTARG ;;
        s) suffix="-$OPTARG" ;;
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

echo "This may take a while..."

# extract
tar xzf ${pipeline_package_path} -C ${install_temp_path}

# load the Roslin Pipeline settings.sh found in tgz
source ${install_temp_path}/setup/config/settings.sh

# new version string
new_roslin_pipeline_version="${ROSLIN_PIPELINE_VERSION}-dev-${USER}${suffix}"

# replace
sed -i.bak "s/export ROSLIN_PIPELINE_VERSION=\"$ROSLIN_PIPELINE_VERSION\"/export ROSLIN_PIPELINE_VERSION=\"$new_roslin_pipeline_version\"/g" ${install_temp_path}/setup/config/settings.sh

# update examples
find ${install_temp_path}/setup/examples -name "run-example.sh" | \
    xargs -I {} sed -i "s/pipeline_name_version=\"${ROSLIN_PIPELINE_NAME}\/${ROSLIN_PIPELINE_VERSION}\"/pipeline_name_version=\"${ROSLIN_PIPELINE_NAME}\/${new_roslin_pipeline_version}\"/g" {}

# new tgz
new_tgz="roslin-${ROSLIN_PIPELINE_NAME}-pipeline-v${new_roslin_pipeline_version}.tgz"

# tar gzip
tar cvzf ${new_tgz} -C ${install_temp_path} .

echo
echo "old: ${ROSLIN_PIPELINE_VERSION}"
echo "new: ${new_roslin_pipeline_version}"
echo
echo "New deployable package: ${new_tgz}"
echo
echo "Note that the examples included might not have been fully converted to use this dev copy."
