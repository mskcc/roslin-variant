export PRISM_VERSION="1.0.0"

# fixme: use / in the production
PRISM_ROOT="/ifs/work/chunj/prism-proto"

#--> the following two paths will be supplied to singularity as bind points

# binaries, executables, scripts
export PRISM_BIN_PATH="${PRISM_ROOT}/prism"

# reference data (e.g. genome assemblies)
export PRISM_DATA_PATH="${PRISM_ROOT}/ifs"

#<--

# input files to pipeline (e.g. fastq files)
export PRISM_INPUT_PATH="${PRISM_ROOT}/ifs/prism/inputs"

# path to singularity executable
# override this if you want to test a different version of singularity
export PRISM_SINGULARITY_PATH="/usr/bin/singularity"
