#!/bin/bash

# e.g. list='cmo-abra cmo-bwa-mem'

if [ -z "$*" ]
then
  list=`find . -maxdepth 1 -type d -not -path . -exec bash -c "echo {} | cut -c3-" \;`
else
  list="$*"
fi

for dir in $list
do

  case "$dir" in

    data)
      # skip the data directory
      continue
      ;;

    bsub-of-prism-runner)
      bsub -q test -K -cwd ./bsub-of-prism-runner \
        -eo ../results.bsub-of-prism-runner.stderr.txt \
        -oo ../results.bsub-of-prism-runner.txt \
        "prism-runner.sh -w samtools/1.3.1/samtools-sam2bam.cwl -i ./inputs.yaml -b lsf"
      ;;

    *)
      echo "Starting: ${dir}..."

      cd $dir

      if [ -e "./run-example.sh" ]
      then
        ./run-example.sh | tee ../results.$dir.txt
      fi

      cd ..
      ;;

  esac

done
