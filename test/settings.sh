export PRISM_VERSION="1.0.0"
export PRISM_BIN_PATH="/vagrant/test/mock/bin"
export PRISM_DATA_PATH="/vagrant/test/mock/data"
export PRISM_EXTRA_BIND_PATH="/vagrant/test/mock/scratch"
export PRISM_INPUT_PATH="/vagrant/test/mock/inputs"

# space-separated
export SINGULARITY_BIND_POINTS="$PRISM_BIN_PATH $PRISM_DATA_PATH /scratch"
