#!/bin/bash

# define bind points that need to be created inside containers
# use a space character as a delimiter if you need to define multiple bind points
export SINGULARITY_BIND_POINTS="/ifs/work/chunj/prism-proto/prism /ifs/work/chunj/prism-proto/ifs /ifs/work/chunj/prism-proto/ifs/prism/outputs /ifs/work/chunj/prism-proto/ifs/prism/inputs /scratch"