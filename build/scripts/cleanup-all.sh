#!/bin/bash
script_rel_dir=`dirname ${BASH_SOURCE[0]}`
script_dir=`python -c "import os; print os.path.abspath('${script_rel_dir}')"`

exec $script_dir/cleanup-images.sh
exec $script_dir/cleanup-cwl.sh
