#!/bin/bash

# define bind points that need to be created inside containers
# use a space character as a delimiter if you need to define multiple bind points
export SINGULARITY_BIND_POINTS="/ifs/work/pi/roslin-pipelines/bin /ifs/work/pi/roslin-pipelines/resources /ifs/work/pi/roslin-pipelines/outputs /ifs/work/pi/roslin-pipelines/workspace /scratch /ifs"