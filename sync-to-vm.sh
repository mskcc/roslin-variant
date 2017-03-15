#!/bin/bash

USERNAME="chunj"
HOST="127.0.0.1"
PORT="7777"
DRY_RUN=""

usage()
{
cat << EOF

USAGE: $0 [options]

OPTIONS:
   -u      ssh username
   -p      ssh port
   -d      dry run (show what would have been transferred)
   -h      help

EOF
}

while getopts “u:p:hd” OPTION
do
    case $OPTION in
        u) USERNAME=$OPTARG ;;
        p) PORT=$OPTARG ;;
        d) DRY_RUN="--dry-run" ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done



# ssh-keygen -R "[127.0.0.1]:7000"

# not reliable
# scp -rp -P ${PORT} ./setup/ ${USERNAME}@${HOST}:/tmp/prism-setup/

rsync ${DRY_RUN} -ave "ssh -p ${PORT}" --delete --exclude=".DS_Store" ./setup/ ${USERNAME}@${HOST}:/tmp/prism-setup/
