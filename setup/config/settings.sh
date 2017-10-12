export ROSLIN_PIPELINE_DESCRIPTION="Roslin Variant Pipeline v1.3.0"

# Roslin pipeline name/version
export ROSLIN_PIPELINE_NAME="variant"
export ROSLIN_PIPELINE_VERSION="1.3.0"

# which version of Roslin Core is required?
export ROSLIN_CORE_MIN_VERSION="1.0.0"
export ROSLIN_CORE_MAX_VERSION="1.0.0"

# Roslin pipeline root path
ROSLIN_PIPELINE_ROOT="/ifs/work/pi/roslin-pipelines/${ROSLIN_PIPELINE_NAME}/${ROSLIN_PIPELINE_VERSION}"

#--> the following paths will be supplied to singularity as bind points

# binaries, executables, scripts
export ROSLIN_PIPELINE_BIN_PATH="${ROSLIN_PIPELINE_ROOT}/bin"

# reference data (e.g. genome assemblies)
export ROSLIN_PIPELINE_DATA_PATH="${ROSLIN_PIPELINE_ROOT}/resources"

# other paths that we'd like to bind (space separated)
export ROSLIN_EXTRA_BIND_PATH="/scratch /ifs"

# output path
export ROSLIN_PIPELINE_OUTPUT_PATH="${ROSLIN_PIPELINE_ROOT}/outputs"

# workspace
export ROSLIN_PIPELINE_WORKSPACE_PATH="${ROSLIN_PIPELINE_ROOT}/workspace"

#<--

# path to singularity executable
# singularity is expected to be found at the same location regardless of the nodes you're on
# override this if you want to test a different version of singularity.
export ROSLIN_SINGULARITY_PATH="/usr/bin/singularity"

# cmo
export ROSLIN_CMO_VERSION="1.8.1"
export ROSLIN_CMO_BIN_PATH="/ifs/work/pi/cmo_package_archive/1.8.1/bin"
export ROSLIN_CMO_PYTHON_PATH="/ifs/work/pi/cmo_package_archive/1.8.1/lib/python2.7/site-packages"