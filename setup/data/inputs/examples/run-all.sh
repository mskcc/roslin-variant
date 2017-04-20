#!/bin/bash

# e.g. list='cmo-abra cmo-bwa-mem'
list=`find . -maxdepth 1 -type d -not -path . -exec bash -c "echo {} | cut -c3-" \;`

for dir in $list
do

  # skip the data directory
  if [ "$dir" == "data" ]; then continue; fi

  # skip bsub-of-prism-runner
  # we will treat this separately at the end
  if [ "$dir" == "bsub-of-prism-runner" ]; then continue; fi

  echo $dir

  cd $dir

  if [ -e "./run-example.sh" ]
  then
    ./run-example.sh | tee ../results.$dir.txt
  fi

  cd ..

done

# bsub-of-prism-runner
bsub -q test -K -cwd ./bsub-of-prism-runner \
  -eo ../results.bsub-of-prism-runner.stderr.txt \
  -oo ../results.bsub-of-prism-runner.txt \
  "./run-example.sh"

# module-2
# bsub -q test -K -cwd ./module-2 \
#   -eo ../results.module-2.stderr.txt \
#   -oo ../results.module-2.txt \
#   "./run-example.sh"
