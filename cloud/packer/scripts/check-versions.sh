#!/bin/bash -e

version_file="/var/log/roslin-software-versions.txt"

write()
{
    echo $1 | sudo tee --append ${version_file}
}

# $1 name
# $2 command to run to get version
check()
{
    version=`$2 2>&1`
    write "$1 : $version"
}

sudo rm -rf $version_file

check "python" "python --version"
check "pip" "pip --version"
check "aws" "aws --version"
check "cwltoil" "cwltoil --version"
check "docker" "docker --version"
check "node" "node --version"
check "singularity" "singularity --version"

# cmo works a bit different, so...
# need cmo_resources.json in order to import cmo.
# cmo_version=`CMO_RESOURCE_CONFIG="/usr/local/bin/cmo_resources.json" python -c "import cmo; print cmo.__version__"`
# write "cmo : $cmo_version"
