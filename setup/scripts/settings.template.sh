export PRISM_VERSION="{{ version }}"

# fixme: use / in the production
PRISM_ROOT="{{ root }}"

#--> the following paths will be supplied to singularity as bind points

# binaries, executables, scripts
export PRISM_BIN_PATH="${PRISM_ROOT}/{{ binding_bin }}"

# reference data (e.g. genome assemblies)
export PRISM_DATA_PATH="${PRISM_ROOT}/{{ binding_data }}"

# other paths that we'd like to bind (space separated)
export PRISM_EXTRA_BIND_PATH="{{ binding_extra }}"

#<--

# input files to pipeline (e.g. fastq files)
export PRISM_INPUT_PATH="${PRISM_ROOT}/{{ examples }}"

# path to singularity executable
# singularity is expected to be found at the same location regardless of the nodes you're on
# override this if you want to test a different version of singularity.
export PRISM_SINGULARITY_PATH="/usr/bin/singularity"
