# which version of Roslin Core is required?
export ROSLIN_CORE_MIN_VERSION="{{ core_min_version }}"
export ROSLIN_CORE_MAX_VERSION="{{ core_max_version }}"

# Roslin pipeline name/version
export ROSLIN_PIPELINE_NAME="{{ pipeline_name }}"
export ROSLIN_PIPELINE_VERSION="{{ pipeline_version }}"

# Roslin root path
ROSLIN_ROOT="{{ pipeline_root }}"

#--> the following paths will be supplied to singularity as bind points

# binaries, executables, scripts
export ROSLIN_BIN_PATH="${ROSLIN_ROOT}/{{ binding_core }}"

# reference data (e.g. genome assemblies)
export ROSLIN_DATA_PATH="${ROSLIN_ROOT}/{{ binding_data }}"

# other paths that we'd like to bind (space separated)
export ROSLIN_EXTRA_BIND_PATH="{{ binding_extra }}"

# output path
export ROSLIN_OUTPUT_PATH="${ROSLIN_ROOT}/{{ binding_output }}"

# workspace
export ROSLIN_INPUT_PATH="${ROSLIN_ROOT}/{{ binding_workspace }}"

#<--

# path to singularity executable
# singularity is expected to be found at the same location regardless of the nodes you're on
# override this if you want to test a different version of singularity.
export ROSLIN_SINGULARITY_PATH="/usr/bin/singularity"

# cmo
export ROSLIN_CMO_VERSION="{{ dependencies_cmo_version }}"
export ROSLIN_CMO_PYTHON_PATH="{{ dependencies_cmo_python_path }}"
