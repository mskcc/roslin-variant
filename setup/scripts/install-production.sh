#!/bin/bash

usage()
{
cat << EOF

USAGE: $0 [options]

OPTIONS:

   -s      System-wide installation:
           PATH and ENV will be configured in /etc/profile.d

   -l      Local installation
           PATH and ENV will be configured in ~/.profile

   -h      help

EOF
}

while getopts “slh” OPTION
do
    case $OPTION in
        s) export ROSLIN_SYSTEM_WIDE_INSTALL="YES" ;;
        l) export ROSLIN_SYSTEM_WIDE_INSTALL="NO" ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z $ROSLIN_SYSTEM_WIDE_INSTALL ]
then
    usage
    exit 1
fi


if [ "$ROSLIN_SYSTEM_WIDE_INSTALL" == "YES" ]
then
    cp ./settings.sh /etc/profile.d/prism-pipeline-envs.sh
fi

./configure-directory.sh

./install-sing.sh

./install-roslin-runner.sh

./install-tools.sh

./install-cwl-wrappers.sh

# only supported in RHEL7.3+
# ./configure-singularity.sh

# you must run this at the very end
./install-prism-setup.sh

