#!/bin/bash

# define bind points that need to be created inside containers
# use a space character as a delimiter if you need to define multiple bind points
export SINGULARITY_BIND_POINTS="/ifs/work/pi/roslin-test/31afdfef-c16f-4800-9b73-90495818500c/bin /ifs/work/pi/roslin-test/31afdfef-c16f-4800-9b73-90495818500c/resources /ifs/work/pi/roslin-test/31afdfef-c16f-4800-9b73-90495818500c/outputs /ifs/work/pi/roslin-test/31afdfef-c16f-4800-9b73-90495818500c/workspace /scratch /ifs"