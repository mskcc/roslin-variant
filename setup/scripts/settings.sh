export PRISM_VERSION="1.0.0"

PRISM_ROOT="/ifs/work/pi"

#--> the following paths will be supplied to singularity as bind points

# binaries, executables, scripts
export PRISM_BIN_PATH="${PRISM_ROOT}/roslin"

# reference data (e.g. genome assemblies)
export PRISM_DATA_PATH="${PRISM_ROOT}/resources"

# other paths that we'd like to bind (space separated)
export PRISM_EXTRA_BIND_PATH="/scratch /ifs"

# output path
export PRISM_OUTPUT_PATH="${PRISM_ROOT}/roslin/outputs"

# workspace
export PRISM_INPUT_PATH="${PRISM_ROOT}/workspace"

#<--

# path to singularity executable
# singularity is expected to be found at the same location regardless of the nodes you're on
# override this if you want to test a different version of singularity.
export PRISM_SINGULARITY_PATH="/usr/bin/singularity"