#!/bin/bash

PIPELINE_VERSION="1.0.0"

MY_TEMP_DIRECTORY="/vagrant/build/tmp"

# directory where Dockerfile, Singularity, and images are stored
CONTAINER_DIRECTORY="/vagrant/build/containers"

CWL_WRAPPER_DIRECTORY="/vagrant/build/cwl-wrappers"

# docker repository name (in docker hub)
DOCKER_REPO_NAME="hisplan"

# e.g. full name would be "hisplan/pipeline-trimgalore"
DOCKER_REPO_TOOLNAME_PREFIX="pipeline"