#!/bin/bash

# define bind points that need to be created inside containers
# use a space character as a delimiter if you need to define multiple bind points
export SINGULARITY_BIND_POINTS="/ifs/work/pi/roslin /ifs/work/pi/resources /ifs/work/pi/roslin/outputs /ifs/work/pi/workspace /scratch /ifs"