export PRISM_VERSION="1.0.0"
export PRISM_BIN_PATH="/vagrant/test/mock/bin"
export PRISM_DATA_PATH="/vagrant/test/mock/data"
export PRISM_EXTRA_BIND_PATH="/vagrant/test/mock/scratch1 /vagrant/test/mock/scratch2"
export PRISM_INPUT_PATH="/vagrant/test/mock/inputs"
export PRISM_OUTPUT_PATH="/vagrant/test/mock/outputs"

# space-separated
export SINGULARITY_BIND_POINTS="$PRISM_BIN_PATH $PRISM_DATA_PATH $PRISM_INPUT_PATH $PRISM_OUTPUT_PATH $PRISM_EXTRA_BIND_PATH"
