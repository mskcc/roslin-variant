#!/bin/bash

if [ -z "$1" ]
then
    echo "Need LSF Project Name. (e.g. Proj_5088_B:fe21e822-4bfa-11e7-9c2b-645106efb11c)""
    exit 1
fi

bjobs -a -P $1 -o "jobid proj_name job_name stat delimiter=','" | sort -k 1 -n | tabulate --sep , -1 --format orgtbl
