#!/bin/bash

# define bind points that need to be created inside containers
# use a space character as a delimiter if you need to define multiple bind points
export TMPDIR="/scratch"
export TMP="/scratch"
export SINGULARITY_BIND_POINTS="{{ binding_points}}"
