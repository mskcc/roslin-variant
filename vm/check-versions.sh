#!/bin/bash

version_file="/var/log/prism-software-versions.txt"

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
check "docker" "docker --version"
check "singularity" "singularity --version"
