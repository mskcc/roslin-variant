#!/bin/bash

cur_dir=`pwd`

# where example inputs.yaml and run-example.sh are placed
tools_dir='..'

# where tool output will be placed
output_dir="`pwd`/outputs"
mkdir -p ${output_dir}

# by default, test all tools in the examples directory
tools_list=`find ${tools_dir} -maxdepth 1 -type d -not -path .. -exec bash -c "echo {} | cut -c4-" \; | grep -P -v "^_" | sort`

usage()
{
cat << EOF

USAGE: `basename $0` [options]

OPTIONS:

   -t      Specify list of tools to be run, space-separated (e.g. cmo-abra cmo-bwa-mem)
   -z      Show list of tools that can be run
   -h      Help

EOF
}

while getopts “t:zh” OPTION
do
    case $OPTION in
        t) tools_list=$OPTARG ;;
        z) for tool in $tools_list; do echo $tool; done; exit 1 ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

for dir in $tools_list
do

  # skip if directory name starts with _  
  if [[ $dir == _* ]]
  then
    continue
  fi

  case "$dir" in

    unit-test)
      # skip this directory
      continue
      ;;

    data)
      # skip the data directory
      continue
      ;;

    bsub-of-prism-runner)
      bsub -q test -K -cwd ${tools_dir}/bsub-of-prism-runner \
        -eo ${output_dir}/bsub-of-prism-runner.stderr.txt \
        -oo ${output_dir}/bsub-of-prism-runner.txt \
        "prism-runner.sh -w samtools/1.3.1/samtools-sam2bam.cwl -i ./inputs.yaml -b lsf"
      ;;

    Proj_DEV_0002)
      # skip this directory
      ;;

    *)
      # $dir is the tool name
      echo "Starting: ${dir}..."

      cd ${tools_dir}/${dir}

      if [ -e "./run-example.sh" ]
      then
        # run in background
        ./run-example.sh | tee ${output_dir}/$dir.txt &
      fi

      cd ${cur_dir}
      ;;

  esac

done

# wait till all the background processes are done
wait
