export ROSLIN_PIPELINE_DESCRIPTION="{{ pipeline_description }}"

# Roslin pipeline name/version
export ROSLIN_PIPELINE_NAME="{{ pipeline_name }}"
export ROSLIN_PIPELINE_VERSION="{{ pipeline_version }}"

# which version of Roslin Core is required?
export ROSLIN_CORE_MIN_VERSION="{{ core_min_version }}"
export ROSLIN_CORE_MAX_VERSION="{{ core_max_version }}"

# Roslin pipeline root path
ROSLIN_PIPELINE_ROOT="{{ pipeline_root }}/${ROSLIN_PIPELINE_NAME}/${ROSLIN_PIPELINE_VERSION}"

#--> the following paths will be supplied to singularity as bind points

# binaries, executables, scripts
export ROSLIN_PIPELINE_BIN_PATH="${ROSLIN_PIPELINE_ROOT}/{{ binding_core }}"

# reference data (e.g. genome assemblies)
export ROSLIN_PIPELINE_DATA_PATH="${ROSLIN_PIPELINE_ROOT}/{{ binding_data }}"

# other paths that we'd like to bind (space separated)
export ROSLIN_EXTRA_BIND_PATH="{{ binding_extra }}"

# output path
export ROSLIN_PIPELINE_OUTPUT_PATH="${ROSLIN_PIPELINE_ROOT}/{{ binding_output }}"

# workspace
export ROSLIN_PIPELINE_WORKSPACE_PATH="${ROSLIN_PIPELINE_ROOT}/{{ binding_workspace }}"

#<--

# path to singularity executable
# singularity is expected to be found at the same location regardless of the nodes you're on
# override this if you want to test a different version of singularity.
export ROSLIN_SINGULARITY_PATH="/opt/common/CentOS_6-dev/singularity/singularity-2.4.2/bin/singularity"

# cmo
export ROSLIN_CMO_VERSION="{{ dependencies_cmo_version }}"
export ROSLIN_CMO_BIN_PATH="{{ dependencies_cmo_bin_path }}"
export ROSLIN_CMO_PYTHON_PATH="{{ dependencies_cmo_python_path }}"

# toil
export ROSLIN_TOIL_VERSION="{{ dependencies_toil_version }}"
export ROSLIN_TOIL_INSTALL_PATH="{{ dependencies_toil_install_path }}"
