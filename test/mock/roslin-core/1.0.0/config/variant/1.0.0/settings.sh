# fake settings for Rosline Variant Pipeline 1.0.0
export ROSLIN_PIPELINE_NAME="variant"
export ROSLIN_PIPELINE_VERSION="1.0.0"
export ROSLIN_BIN_PATH="/vagrant/test/mock/roslin-pipelines/variant/1.0.0/bin"
export ROSLIN_DATA_PATH="/vagrant/test/mock/roslin-pipelines/variant/1.0.0/data"
export ROSLIN_EXTRA_BIND_PATH="/vagrant/test/mock/scratch1 /vagrant/test/mock/scratch2"
export ROSLIN_INPUT_PATH="/vagrant/test/mock/roslin-pipelines/variant/1.0.0/inputs"
export ROSLIN_OUTPUT_PATH="/vagrant/test/mock/roslin-pipelines/variant/1.0.0/outputs"
export ROSLIN_CMO_VERSION="1.6.7"
export ROSLIN_CMO_PYTHON_PATH="/usr/local/lib/python2.7/site-packages/"

# space-separated
export SINGULARITY_BIND_POINTS="$ROSLIN_BIN_PATH $ROSLIN_DATA_PATH $ROSLIN_INPUT_PATH $ROSLIN_OUTPUT_PATH $ROSLIN_EXTRA_BIND_PATH"
