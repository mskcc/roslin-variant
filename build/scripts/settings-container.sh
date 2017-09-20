#!/bin/bash

# define bind points that need to be created inside containers
# use a space character as a delimiter if you need to define multiple bind points
export SINGULARITY_BIND_POINTS="/ifs/work/pi/roslin-pipelines/variant/bin /ifs/work/pi/roslin-pipelines/variant/resources /ifs/work/pi/roslin-pipelines/variant/outputs /ifs/work/pi/roslin-pipelines/variant/workspace /scratch /ifs"