export PRISM_VERSION="1.0.0"

# fixme: use / in the production
PRISM_ROOT="/scratch/prism-test"

# the following two paths will be supplied to singularity as bind points
# 1. PRISM_BIN_PATH
# 2. PRISM_DATA_PATH

# binaries, executables, scripts
export PRISM_BIN_PATH="${PRISM_ROOT}/prism"

# reference data (e.g. genome assemblies)
export PRISM_DATA_PATH="${PRISM_ROOT}/ifs"


# input files to pipeline (e.g. fastq files)
export PRISM_INPUT_PATH="${PRISM_ROOT}/ifs/prism/inputs"
