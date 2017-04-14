#!/bin/bash

usage()
{
cat << EOF

USAGE: `basename $0` [options]

Debug Module 2

OPTIONS:

   -a      Debug from ABRA
   -b      Debug from PrintReads

EOF
}

cwl_name=""

while getopts “ab” OPTION
do
    case $OPTION in
        a) cwl_name='module-2a.cwl' ;;
        b) cwl_name='module-2b.cwl' ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z $cwl_name ]
then
    usage
    exit 1
fi

# modify debug-inputs.yaml.template to have an user-specific, collision safe working directory
uuid=`python -c 'import uuid; print str(uuid.uuid1())'`
tmpdir="$HOME/tmp/$uuid"
eval "echo \"$(cat debug-inputs.yaml.template)\"" > debug-inputs.yaml

prism-runner.sh \
    -w ${cwl_name} \
    -i debug-inputs.yaml \
    -b singleMachine
