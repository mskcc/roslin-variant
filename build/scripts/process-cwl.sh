#!/bin/sh

usage()
{
cat << EOF

USAGE: $0 [options]

OPTIONS:
   -t      Tool name (e.g. trimgalore)
   -v      Version of the tool (e.g. 0.4.3)
   -c      cmo wrapper name (e.g cmo_trimgalore)
   -d      Skip installation of cmo and gxargparse (only for debugging)
   -h      Help

e.g. $0 -t trimgalore -v 0.4.3 -c cmo_trimgalore

EOF
}

# flag for skipping cmo & gxargparse setup
SKIP_CMO_GXARGPARSE_INSTALL=0

while getopts “t:v:c:dh” OPTION
do
    case $OPTION in
        t) TOOL_NAME=$OPTARG ;;
        v) TOOL_VERSION=$OPTARG ;;
        c) CMO_WRAPPER=$OPTARG ;;        
        d) SKIP_CMO_GXARGPARSE_INSTALL=1 ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z $TOOL_NAME} ] || [ -z $TOOL_VERSION ] || [ -z $CMO_WRAPPER ]
then
    usage
    exit 1
fi

# convert _ to -
CMO_WRAPPER_WITH_DASH=`echo "${CMO_WRAPPER}" | sed "s/_/-/g"`

TOOL_DIRECTORY="/cwl-wrappers/${CMO_WRAPPER_WITH_DASH}/${TOOL_VERSION}"

# skip if debugging is on
if [ $SKIP_CMO_GXARGPARSE_INSTALL -eq 0 ]
then

    # local cache for python pip
    chown root:root /var/cache
    export XDG_CACHE_HOME="/var/cache"

    # manually enable local cache for alpine linux
    mkdir -p /var/cache/apk
    ln -s /var/cache/apk /etc/apk/cache

    # deprecate: libmagic is in the edge repository
    # echo "http://dl-3.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
    # apk upgrade --update-cache --available

    CMO_RESOURCE_CONFIG="/opt/common/CentOS_6-dev/cmo/cmo_resources.json"

    apk update
    apk add git tree
    apk add python py-pip python-dev build-base
    pip install --upgrade pip
    pip install ruamel.yaml

    # install cmo
    # pip install python-daemon \
    #     && cd /tmp && git clone https://github.com/mskcc/cmo.git \
    #     && cd cmo && python setup.py install \
    #     && mkdir -p `dirname ${CMO_RESOURCE_CONFIG}` \
    #     && cp /tmp/cmo/cmo/data/cmo_resources.json ${CMO_RESOURCE_CONFIG}

    # # install gxargparse
    # apk add python-dev libxml2-dev libxslt-dev libgcrypt-dev libmagic \
    #     && pip install future \
    #     && cd /tmp \
    #     && git clone https://github.com/common-workflow-language/gxargparse.git \
    #     && cd gxargparse \
    #     && python setup.py install --user

    # install cmo
    pip install python-daemon \
        && cd /tmp \
        && cd cmo && python setup.py install \
        && mkdir -p `dirname ${CMO_RESOURCE_CONFIG}` \
        && cp /tmp/cmo/cmo/data/cmo_resources.json ${CMO_RESOURCE_CONFIG}

    # install gxargparse
    apk add python-dev libxml2-dev libxslt-dev libgcrypt-dev libmagic yaml-dev py-lxml \
        && pip install future \
        && cd /tmp \
        && cd gxargparse \
        && python setup.py install --user
fi

mkdir -p ${TOOL_DIRECTORY}

# deprecate: gxargparse PYTHONPATH
# if [ "$CMO_WRAPPER" != "cmo_trimgalore" ]
# then
#     export PYTHONPATH=/root/.local/lib/python2.7/site-packages/gxargparse-0.3.1-py2.7.egg
# fi

# fixme: skip picard until we can generate cwl for picard
if [ "$TOOL_NAME" != "picard" ]
then
    export PYTHONPATH=/root/.local/lib/python2.7/site-packages/gxargparse-0.3.1-py2.7.egg

    # finally, run cmo wrapper and generate cwl
    # https://github.com/common-workflow-language/gxargparse
    ${CMO_WRAPPER} --generate_cwl_tool \
        --directory ${TOOL_DIRECTORY} \
        --output_section ${TOOL_DIRECTORY}/outputs.yaml
        # --basecommand="${CMO_WRAPPER} --version ${TOOL_VERSION}"

    # rename _ to -
    mv ${TOOL_DIRECTORY}/${CMO_WRAPPER}.cwl ${TOOL_DIRECTORY}/${CMO_WRAPPER_WITH_DASH}.cwl
else
    # cwl manually genereated in the past (*.original.cwl) must be placed in the tool directory
    cp ${TOOL_DIRECTORY}/${CMO_WRAPPER_WITH_DASH}.original.cwl ${TOOL_DIRECTORY}/${CMO_WRAPPER_WITH_DASH}.cwl
fi

# replace str with string
sed -i "s/type: \[\"null\", str\]/type: \[\"null\", string\]/g" ${TOOL_DIRECTORY}/${CMO_WRAPPER_WITH_DASH}.cwl
sed -i "s/type: str$/type: string/g" ${TOOL_DIRECTORY}/${CMO_WRAPPER_WITH_DASH}.cwl

# remove unnecessasry u (unicode)
sed -i "s/u'/'/g" ${TOOL_DIRECTORY}/${CMO_WRAPPER_WITH_DASH}.cwl

# postprocess: add version information, requirements section, other necessary 
python /scripts/postprocess_cwl.py \
    -f ${TOOL_DIRECTORY}/${CMO_WRAPPER_WITH_DASH}.cwl \
    -v ${TOOL_VERSION} \
    -r ${TOOL_DIRECTORY}/requirements.yaml \
    -m ${TOOL_DIRECTORY}/metadata.yaml

# postprocess: convert to yaml, make changes, convert back to cwl
if [ -e "${TOOL_DIRECTORY}/postprocess.py" ]
then
    python ${TOOL_DIRECTORY}/postprocess.py \
        -f ${TOOL_DIRECTORY}/${CMO_WRAPPER_WITH_DASH}.cwl
fi

tree ${TOOL_DIRECTORY}

python /scripts/update_prism_resources.py -f /cwl-wrappers/prism_resources.json ${TOOL_NAME} ${TOOL_VERSION} "sing.sh ${TOOL_NAME} ${TOOL_VERSION}"
