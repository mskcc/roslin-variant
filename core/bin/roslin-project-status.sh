#!/bin/bash

out=""
user=$1

if [ -z "$user" ]
then
  user=$USER
fi

proj_list=`bjobs -u $user -o "proj_name" -noheader | sort | uniq`

for proj in $proj_list
do
  cwd=`bjobs -u $user -P $proj -o "sub_cwd" -noheader | sort | uniq`
  outdir=`bjobs -u $user -P "${proj}" -o "exec_cwd" -noheader | sort | uniq | tail -1`
  head=`echo $proj | cut -d: -f1`
  echo "== ${head} =="
  job_list=`bjobs -u $user -P $proj -o 'job_name' -noheader | sort | uniq | awk -F'/' '{ print $NF }'`
  for job in $job_list
  do
    echo " - $job"
  done
  if [ "${outdir}" != "-" ]
  then
    echo " : ${outdir}"
    find ${outdir}/outputs/log -name "*.log" -name "*.log" ! -name "cwltoil.log" -printf " > %f\n" | sort | uniq
  fi
  echo
done
