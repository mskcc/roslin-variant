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
        s) export PRISM_SYSTEM_WIDE_INSTALL="YES" ;;
        l) export PRISM_SYSTEM_WIDE_INSTALL="NO" ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z $PRISM_SYSTEM_WIDE_INSTALL ]
then
    usage
    exit 1
fi


if [ "$PRISM_SYSTEM_WIDE_INSTALL" == "YES" ]
then
    cp ./settings.sh /etc/profile.d/prism-pipeline-envs.sh
else
    mkdir -p ~/.prism
    cp ./settings.sh ~/.prism/
    cp ~/.profile ~/.profile.bak
    
    settings_found=`grep "# PRISM.SETTINGS\$" ~/.profile`
    if [ -z "$settings_found" ]
    then
        echo "for file in ~/.prism/*.sh; do source \$file; done  # PRISM.SETTINGS" | tee -a ~/.profile
    fi
fi

./configure-directory.sh

./install-sing.sh

./install-prism-runner.sh

./install-tools.sh

./install-cwl-wrappers.sh

./configure-test-env.sh

# only supported in RHEL7.3+
# ./configure-singularity.sh

