#!/bin/bash

# define bind points that need to be created inside containers
# use a space character as a delimiter if you need to define multiple bind points
export SINGULARITY_BIND_POINTS="/ifs/work/bergerm1/Innovation/sandbox/ian/roslin-pipelines/bin /ifs/work/bergerm1/Innovation/sandbox/ian/roslin-pipelines/resources /ifs/work/bergerm1/Innovation/sandbox/ian/roslin-pipelines/outputs /ifs/work/bergerm1/Innovation/sandbox/ian/roslin-pipelines/workspace /scratch /ifs"