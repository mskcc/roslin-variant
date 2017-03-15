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

# todo: can we use local repo?
# DOCKER_REPO_NAME="localhost:5000"
# export SINGULARITY_DOCKER_REGISTRY='--registry ${DOCKER_REPO_NAME}'
