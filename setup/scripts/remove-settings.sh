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
    sudo rm -rf /etc/profile.d/prism-pipeline-envs.sh
    sudo rm -rf /etc/profile.d/sing.sh
    sudo rm -rf /etc/profile.d/prism-runner.sh
else
    rm -rf ~/.prism
    grep -v "# PRISM.SETTINGS$" ~/.profile > ~/.profile.tmp
    mv ~/.profile.tmp ~/.profile
fi
