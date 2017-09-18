#!/bin/bash

# define bind points that need to be created inside containers
# use a space character as a delimiter if you need to define multiple bind points
export SINGULARITY_BIND_POINTS="/ifs/work/pi/roslin-pipelines/impact/bin /ifs/work/pi/roslin-pipelines/impact/resources /ifs/work/pi/roslin-pipelines/impact/outputs /ifs/work/pi/roslin-pipelines/impact/workspace /scratch /ifs"