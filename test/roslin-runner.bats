#!/usr/bin/env bats

load 'helpers/bats-support/load'
load 'helpers/bats-assert/load'
load 'helpers/bats-file/load'
load 'helpers/stub/load'

ROSLIN_RUNNER_SCRIPT="/vagrant/core/bin/roslin-runner.sh"

setup() {
  TEST_TEMP_DIR="$(temp_make)"
}

teardown() {
  temp_del "$TEST_TEMP_DIR"
  rm -rf ./outputs
}

# the second line would look like beow
# job uuid followed by a colon (:), then job store uuid
#
# ---> ROSLIN JOB UUID = 11af6ef4-1682-11e7-8e2c-02e45b1a6ece:e5c42a10-34b7-11e7-9db3-645106efb11c"
#
get_job_uuid() {
    line=$(echo "$1" | sed -n "2p")
    echo $(echo $line | cut -c24-59)
}

get_job_store_uuid() {
    line=$(echo "$1" | sed -n "2p")
    echo $(echo $line | cut -c61-)
}

# the fourth line would have all the arguments supplied to roslin-runner
get_args_line() {
    echo $(echo "$1" | sed -n "4p")
}

@test "should have roslin-runner.sh" {

    assert_file_exist ${ROSLIN_RUNNER_SCRIPT}
}


@test "should abort if all the necessary Roslin Core settings are not configured" {

    unset ROSLIN_CORE_VERSION
    unset ROSLIN_CORE_ROOT
    unset ROSLIN_CORE_PATH
    unset ROSLIN_CORE_BIN_PATH
    unset ROSLIN_CORE_CONFIG_PATH

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    assert_line 'Some of the Roslin Core settings are not found.'
}

@test "should abort if ROSLIN_CORE_VERSION is not configured" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    unset ROSLIN_CORE_VERSION

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    assert_line 'Some of the Roslin Core settings are not found.'
}

@test "should abort if ROSLIN_CORE_ROOT is not configured" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    unset ROSLIN_CORE_ROOT

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    assert_line 'Some of the Roslin Core settings are not found.'
}

@test "should abort if ROSLIN_CORE_PATH is not configured" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    unset ROSLIN_CORE_PATH

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    assert_line 'Some of the Roslin Core settings are not found.'
}

@test "should abort if ROSLIN_CORE_BIN_PATH is not configured" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    unset ROSLIN_CORE_BIN_PATH

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    assert_line 'Some of the Roslin Core settings are not found.'
}

@test "should abort if ROSLIN_CORE_CONFIG_PATH is not configured" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    unset ROSLIN_CORE_CONFIG_PATH

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    assert_line 'Some of the Roslin Core settings are not found.'
}

@test "should abort if all the necessary Roslin Pipeline settings are not configured" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    unset ROSLIN_BIN_PATH
    unset ROSLIN_DATA_PATH
    unset ROSLIN_EXTRA_BIND_PATH
    unset ROSLIN_INPUT_PATH
    unset ROSLIN_OUTPUT_PATH
    unset ROSLIN_SINGULARITY_PATH
    unset ROSLIN_CMO_VERSION
    unset ROSLIN_CMO_PYTHON_PATH

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    assert_line 'Some of the Roslin Pipeline settings are not found.'
}

@test "should abort if ROSLIN_BIN_PATH is not configured" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    unset ROSLIN_BIN_PATH

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    assert_line 'Some of the Roslin Pipeline settings are not found.'
}

@test "should abort if ROSLIN_DATA_PATH is not configured" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    unset ROSLIN_DATA_PATH

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    assert_line 'Some of the Roslin Pipeline settings are not found.'
}

@test "should abort if ROSLIN_EXTRA_BIND_PATH is not configured" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh


    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    unset ROSLIN_EXTRA_BIND_PATH

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    assert_line 'Some of the Roslin Pipeline settings are not found.'
}

@test "should abort if ROSLIN_INPUT_PATH is not configured" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    unset ROSLIN_INPUT_PATH

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    assert_line 'Some of the Roslin Pipeline settings are not found.'
}

@test "should abort if ROSLIN_OUTPUT_PATH is not configured" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    unset ROSLIN_OUTPUT_PATH

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    assert_line 'Some of the Roslin Pipeline settings are not found.'
}

@test "should abort if ROSLIN_SINGULARITY_PATH is not configured" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    unset ROSLIN_SINGULARITY_PATH

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    assert_line 'Some of the Roslin Pipeline settings are not found.'
}

@test "should abort if ROSLIN_CMO_VERSION is not configured" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    unset ROSLIN_CMO_VERSION

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    assert_line 'Some of the Roslin Pipeline settings are not found.'
}

@test "should abort if ROSLIN_CMO_PYTHON_PATH is not configured" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    unset ROSLIN_CMO_PYTHON_PATH

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    assert_line 'Some of the Roslin Pipeline settings are not found.'
}

@test "should abort if unable to find Singularity at ROSLIN_SINGULARITY_PATH" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    export ROSLIN_SINGULARITY_PATH="/usr/no-bin/singularity"

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    assert_line 'Unable to find Singularity.'
}

@test "should abort if unable to find python package at ROSLIN_CMO_PYTHON_PATH" {

    # load the Roslin Core/Pipeline settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0.wrong"

    export ROSLIN_SINGULARITY_PATH=`which singularity`

    run ${ROSLIN_RUNNER_SCRIPT}

    # load the Roslin Variant Pipeline settings so that we can check results using env vars
    # load after calling cwltoil otherwise this test could be meaningless
    source ${ROSLIN_CORE_CONFIG_PATH}/${ROSLIN_DEFAULT_PIPELINE_NAME_VERSION}/settings.sh

    assert_failure
    assert_line "Can't find python package at ${ROSLIN_CMO_PYTHON_PATH}"
}

# fixme: this is so MSKCC specific
@test "should skip checking Singularity existence if on one of those leader nodes" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    export ROSLIN_BIN_PATH="a"
    export ROSLIN_DATA_PATH="b"
    export ROSLIN_EXTRA_BIND_PATH="c"
    export ROSLIN_INPUT_PATH="d"
    export ROSLIN_OUTPUT_PATH="e"
    export ROSLIN_SINGULARITY_PATH="/usr/no-bin/singularity"
    export ROSLIN_CMO_VERSION="g"
    export ROSLIN_CMO_PYTHON_PATH="/usr/local/lib/python2.7/site-packages/"

    # stub the 'hostname' command to return 'luna'
    stub hostname 'echo "luna"'

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    refute_line --index 0 --partial 'Unable to find Singularity.'

    # stub the 'hostname' command to return 'selene'
    stub hostname 'echo "selene"'

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    refute_line --index 0 --partial 'Unable to find Singularity.'

    unstubs
}

@test "should abort if workflow or input filename is not supplied" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    run ${ROSLIN_RUNNER_SCRIPT}

    assert_failure
    assert_line --index 0 --partial 'USAGE:'
}

@test "should abort if input file doesn't exit" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i test.yaml

    assert_failure
    assert_line --index 0 --partial 'not found'
}

@test "should abort if batch system is not specified with -b" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    echo "test input" > ${TEST_TEMP_DIR}/test.yaml

    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${TEST_TEMP_DIR}/test.yaml

    assert_failure
    assert_line --index 0 --partial 'USAGE:'
}

@test "should abort if unknown batch system is supplied via -b" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    echo "test input" > ${TEST_TEMP_DIR}/test.yaml

    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${TEST_TEMP_DIR}/test.yaml -b xyz

    assert_failure
    assert_line --index 0 --partial 'USAGE:'
}

@test "should abort if mesos is selected for batch system" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    echo "test input" > ${TEST_TEMP_DIR}/test.yaml

    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${TEST_TEMP_DIR}/test.yaml -b mesos

    assert_failure
    assert_line --index 0 --partial 'Unsupported'
}

@test "should abort if output directory already exists" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    input_filename="${TEST_TEMP_DIR}/test.yaml"
    echo "test input" > ${input_filename}

    # stub cwltoil to echo out whatever the parameters supplied
    stub cwltoil 'echo "$@"'

    # setup different output directory
    # and put something in there
    different_output_dir="${TEST_TEMP_DIR}/diff"
    mkdir -p ${different_output_dir}
    echo "test" > ${different_output_dir}/hello.txt

    # call roslin-runner with -o
    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${input_filename} -b singleMachine -o ${different_output_dir}

    assert_failure
    assert_line --partial 'The specified output directory already exists'

    # tear down
    rm -rf ${different_output_dir}

    unstubs
}

@test "should output job UUID at the beginning and the end" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    echo "test input" > ${TEST_TEMP_DIR}/test.yaml

    # stub cwltoil to echo out whatever the parameters supplied
    stub cwltoil 'echo "$@"'

    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${TEST_TEMP_DIR}/test.yaml -b lsf

    assert_success

    # the line 0 and line 2 would have something like this:
    #
    # ROSLIN JOB UUID = 11af6ef4-1682-11e7-8e2c-02e45b1a6ece
    #
    # note that bats doesn't count empty lines
    assert_line --index 0 --regexp 'JOB UUID = [a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}'
    assert_line --index 3 --regexp 'JOB UUID = [a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}'

    # get job UUID
    job_uuid=$(get_job_uuid "$output")

    # check the content of job_uuid file
    assert_equal "${job_uuid}" `cat ./outputs/job-uuid`

    unstubs
}

@test "should correctly construct the parameters when calling cwltoil" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    input_filename="${TEST_TEMP_DIR}/test.yaml"
    echo "test input" > ${input_filename}

    # stub cwltoil to echo out whatever the parameters supplied
    stub cwltoil 'echo "$@"'

    workflow_filename='abc.cwl'

    run ${ROSLIN_RUNNER_SCRIPT} -w ${workflow_filename} -i ${input_filename} -b lsf

    # load the Roslin Variant Pipeline settings so that we can check results using env vars
    # load after calling cwltoil otherwise this test could be meaningless
    source ${ROSLIN_CORE_CONFIG_PATH}/${ROSLIN_DEFAULT_PIPELINE_NAME_VERSION}/settings.sh

    assert_success

    # check versions of Roslin Core, Roslin Pipeline, CMO
    assert_line --index 1 "VERSIONS: roslin-core-${ROSLIN_CORE_VERSION}, roslin-${ROSLIN_PIPELINE_NAME}-${ROSLIN_PIPELINE_VERSION}, cmo-${ROSLIN_CMO_VERSION}"

    # get job UUID
    job_uuid=$(get_job_uuid "$output")

    # get job store UUID
    job_store_uuid=$(get_job_store_uuid "$output")

    # parse argument line (each arg separated by a single space character)
    # and then split to make an array
    args_line=$(get_args_line "$output")
    read -r -a args <<< "$args_line"

    # example argument line:
    #
    # /vagrant/test/mock/bin/cwl/abc.cwl
    # /tmp/roslin-runner.bats-12-7uktFHNZ4w/test.yaml
    # --jobStore file:///vagrant/test/mock/bin/tmp/jobstore-78377068-1682-11e7-8e2c-02e45b1a6ece
    # --defaultDisk 10G
    # --preserve-environment PATH PYTHONPATH ROSLIN_DATA_PATH ROSLIN_BIN_PATH ROSLIN_EXTRA_BIND_PATH ROSLIN_INPUT_PATH ROSLIN_OUTPUT_PATH ROSLIN_SINGULARITY_PATH CMSOURCE_CONFIG
    # --no-container
    # --not-strcit
    # --disableCaching
    # --realTimeLogging
    # --maxLogFileSize 0
    # --writeLogs /vagrant/test/outputs/log
    # --logFile /vagrant/test/outputs/log/cwltoil.log
    # --workDir /vagrant/test/mock/bin/tmp
    # --outdir: /vagrant/test/outputs
    # --batchSystem lsf
    # --stats
    # --logDebug
    # --cleanWorkDir never
    #

    # check workflow filename (positional arg 0)
    assert_equal "${args[0]}" "${ROSLIN_BIN_PATH}/cwl/${workflow_filename}"

    # check input filename (positional arg 1)
    assert_equal "${args[1]}" "${input_filename}"

    # check --jobStore
    assert_line --index 2 --partial "--jobStore file://${ROSLIN_BIN_PATH}/tmp/jobstore-${job_store_uuid}"

    # check --preserve-environment
    assert_line --index 2 --partial "--preserve-environment PATH PYTHONPATH ROSLIN_DATA_PATH ROSLIN_BIN_PATH ROSLIN_EXTRA_BIND_PATH ROSLIN_INPUT_PATH ROSLIN_OUTPUT_PATH ROSLIN_SINGULARITY_PATH"

    # check --no-container
    assert_line --index 2 --partial "--no-container"

    # check --disableCaching
    assert_line --index 2 --partial "--disableCaching"

    # check --maxLogFileSize
    assert_line --index 2 --partial "--maxLogFileSize 0"

    # check --realTimeLogging
    assert_line --index 2 --partial "--realTimeLogging"

    # check --realTimeLogging
    assert_line --index 2 --partial "--realTimeLogging"

    # check --workDir
    assert_line --index 2 --partial "--workDir ${ROSLIN_BIN_PATH}/tmp"

    # by default, debug-related parameters should not be added
    refute_line --index 2 --partial "--logDebug --cleanWorkDir never"

    # check --not-strcit
    assert_line --index 2 --partial "--not-strict"

    unstubs
}

@test "should correctly handle -d (debug mode) parameter when calling cwltoil" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    input_filename="${TEST_TEMP_DIR}/test.yaml"
    echo "test input" > ${input_filename}

    # stub cwltoil to echo out whatever the parameters supplied
    stub cwltoil 'echo "$@"'

    # call roslin-runner with -b lsf -d
    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${input_filename} -b lsf -d

    assert_success

    # check lsf-related
    assert_line --index 2 --partial "--logDebug --cleanWorkDir never"

    unstubs
}

@test "should correctly construct the parameters when calling cwltoil for lsf" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    input_filename="${TEST_TEMP_DIR}/test.yaml"
    echo "test input" > ${input_filename}

    # stub cwltoil to echo out whatever the parameters supplied
    stub cwltoil 'echo "$@"'

    # call roslin-runner with -b lsf
    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${input_filename} -b lsf

    assert_success

    # check lsf-related
    assert_line --index 2 --partial "--batchSystem lsf --stats"

    unstubs
}

@test "should correctly construct the parameters when calling cwltoil for singleMachine" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    input_filename="${TEST_TEMP_DIR}/test.yaml"
    echo "test input" > ${input_filename}

    # stub cwltoil to echo out whatever the parameters supplied
    stub cwltoil 'echo "$@"'

    # call roslin-runner with -b singleMachine
    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${input_filename} -b singleMachine

    assert_success

    # check lsf-related
    assert_line --index 2 --partial "--batchSystem singleMachine"

    unstubs
}

@test "should correctly handle -o (output directory) parameter when calling cwltoil" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    input_filename="${TEST_TEMP_DIR}/test.yaml"
    echo "test input" > ${input_filename}

    # stub cwltoil to echo out whatever the parameters supplied
    stub cwltoil 'echo "$@"'

    # clean up previously created
    rm -rf ./outputs
    rm -rf ./outputs/log

    # call roslin-runner without -o
    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${input_filename} -b singleMachine

    assert_success

    # check whether outputs and outputs/log directories are created
    assert_file_exist ./outputs
    assert_file_exist ./outputs/log

    # check the job-uuid file is created in the correct location
    assert_file_exist ./outputs/job-uuid

    # check --writeLogs
    assert_line --index 2 --partial "--writeLogs /vagrant/test/outputs/log"

    # check --logFile
    assert_line --index 2 --partial "--logFile /vagrant/test/outputs/log/cwltoil.log"

    # check --outdir
    assert_line --index 2 --partial "--outdir /vagrant/test/outputs"

    # setup different output directory
    different_output_dir="${TEST_TEMP_DIR}/diff"

    # call roslin-runner with -o
    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${input_filename} -b singleMachine -o ${different_output_dir}

    assert_success

    # check whether outputs and outputs/log directories are created
    assert_file_exist ${different_output_dir}
    assert_file_exist ${different_output_dir}/log

    # check the job-uuid file is created in the correct location
    assert_file_exist ${different_output_dir}/job-uuid

    # check --outdir
    assert_line --index 2 --partial "--outdir ${different_output_dir}"

    # check --writeLogs
    assert_line --index 2 --partial "--writeLogs ${different_output_dir}/log"

    # check --logFile
    assert_line --index 2 --partial "--logFile ${different_output_dir}/log/cwltoil.log"

    # tear down
    rm -rf ${different_output_dir}

    unstubs
}

@test "should correctly handle -v (pipeline name/version) parameter when calling cwltoil" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    input_filename="${TEST_TEMP_DIR}/test.yaml"
    echo "test input" > ${input_filename}

    # stub cwltoil to echo out whatever the parameters supplied
    stub cwltoil 'echo "$@"'

    pipeline_name="variant"
    pipeline_version="2.0.1"
    pipeline_name_version="${pipeline_name}/${pipeline_version}"
    workflow_filename='abc.cwl'

    # call roslin-runner with -v
    run ${ROSLIN_RUNNER_SCRIPT} -v ${pipeline_name_version} -w ${workflow_filename} -i ${input_filename} -b lsf

    # load the Roslin Variant Pipeline settings so that we can check results using env vars
    # load after calling cwltoil otherwise this test could be meaningless
    source ${ROSLIN_CORE_CONFIG_PATH}/${pipeline_name_version}/settings.sh

    assert_success

    # check versions of Roslin Core, Roslin Pipeline, CMO
    assert_line --index 1 "VERSIONS: roslin-core-${ROSLIN_CORE_VERSION}, roslin-${ROSLIN_PIPELINE_NAME}-${ROSLIN_PIPELINE_VERSION}, cmo-${ROSLIN_CMO_VERSION}"

    # parse argument line (each arg separated by a single space character)
    # and then split to make an array
    args_line=$(get_args_line "$output")
    read -r -a args <<< "$args_line"

    # check workflow filename (positional arg 0)
    assert_equal "${args[0]}" "${ROSLIN_BIN_PATH}/cwl/${workflow_filename}"

    # check --jobStore
    assert_line --index 2 --partial "--jobStore file://${ROSLIN_BIN_PATH}/tmp/jobstore-${job_store_uuid}"

    # check --workDir
    assert_line --index 2 --partial "--workDir ${ROSLIN_BIN_PATH}/tmp"

    unstubs
}

@test "should set CMO_RESOURCE_CONFIG correctly before run, unset after run" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    input_filename="${TEST_TEMP_DIR}/test.yaml"
    echo "test input" > ${input_filename}

    # stub cwltoil to print the value of CMO_RESOURCE_CONFIG
    stub cwltoil 'printenv CMO_RESOURCE_CONFIG'

    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${input_filename} -b singleMachine

    # load the Roslin Variant Pipeline settings so that we can check results using env vars
    # load after calling cwltoil otherwise this test could be meaningless
    source ${ROSLIN_CORE_CONFIG_PATH}/${ROSLIN_DEFAULT_PIPELINE_NAME_VERSION}/settings.sh

    assert_success

    assert_line --index 2 "${ROSLIN_BIN_PATH}/cwl/roslin_resources.json"

    assert_equal `printenv CMO_RESOURCE_CONFIG` ''
}

@test "should correctly handle -r (restart) parameter when calling cwltoil" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    echo "test input" > ${TEST_TEMP_DIR}/test.yaml

    # stub cwltoil to echo out whatever the parameters supplied
    stub cwltoil 'echo "$@"'

    job_store_uuid='some-uuid'

    # call roslin-runner with -r
    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${TEST_TEMP_DIR}/test.yaml -b singleMachine -r ${job_store_uuid}

    # load the Roslin Variant Pipeline settings so that we can check results using env vars
    # load after calling cwltoil otherwise this test could be meaningless
    source ${ROSLIN_CORE_CONFIG_PATH}/${ROSLIN_DEFAULT_PIPELINE_NAME_VERSION}/settings.sh

    assert_success

    # get job store UUID
    job_uuid=$(get_job_uuid "$output")

    # check uuid at the beginning and the end of the output
    assert_line --index 0 --partial "JOB UUID = ${job_uuid}:${job_store_uuid}"
    assert_line --index 3 --partial "JOB UUID = ${job_uuid}:${job_store_uuid}"

    # check --jobStore
    assert_line --index 2 --partial "--jobStore file://${ROSLIN_BIN_PATH}/tmp/jobstore-${job_store_uuid}"

    # check --restart
    assert_line --index 2 --partial "--restart"

    # check the content of job_uuid file
    assert_equal "${job_store_uuid}" `cat ./outputs/job-store-uuid`

    unstubs
}

@test "should set TOIL_LSF_PROJECT correctly before run, unset after run" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    input_filename="${TEST_TEMP_DIR}/test.yaml"
    echo "test input" > ${input_filename}

    # stub cwltoil to print the value of TOIL_LSF_PROJECT
    stub cwltoil 'printenv TOIL_LSF_PROJECT'

    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${input_filename} -b lsf

    assert_success

    # get job UUID
    job_uuid=$(get_job_uuid "$output")

    assert_line --index 2 "default:${job_uuid}"

    assert_equal `printenv TOIL_LSF_PROJECT` ''
}

@test "should set PATH correctly before run" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # configure CMO PYTHONPATH
    export ROSLIN_CMO_PYTHON_PATH="/usr/local/lib/python2.7/site-packages/"

    # create fake input file
    input_filename="${TEST_TEMP_DIR}/test.yaml"
    echo "test input" > ${input_filename}

    # stub cwltoil to print the value of PYTHONPATH
    stub cwltoil 'printenv PATH'

    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${input_filename} -b lsf

    # load the Roslin Variant Pipeline settings so that we can check results using env vars
    # load after calling cwltoil otherwise this test could be meaningless
    source ${ROSLIN_CORE_CONFIG_PATH}/${ROSLIN_DEFAULT_PIPELINE_NAME_VERSION}/settings.sh

    assert_success

    assert_line --index 2 --partial "/ifs/work/pi/cmo_package_archive/${ROSLIN_CMO_VERSION}/bin"
}

@test "should set PYTHONPATH correctly before run" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # configure CMO PYTHONPATH
    export ROSLIN_CMO_PYTHON_PATH="/usr/local/lib/python2.7/site-packages/"

    # create fake input file
    input_filename="${TEST_TEMP_DIR}/test.yaml"
    echo "test input" > ${input_filename}

    # stub cwltoil to print the value of PYTHONPATH
    stub cwltoil 'printenv PYTHONPATH'

    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${input_filename} -b lsf

    assert_success

    assert_line --index 2 "${ROSLIN_CMO_PYTHON_PATH}"
}

@test "should correctly handle -p (CMO project ID) parameter" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    input_filename="${TEST_TEMP_DIR}/test.yaml"
    echo "test input" > ${input_filename}

    # stub cwltoil to print the value of TOIL_LSF_PROJECT
    stub cwltoil 'printenv TOIL_LSF_PROJECT'

    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${input_filename} -b lsf -p Proj_5678_F_2

    assert_success

    # get job UUID
    job_uuid=$(get_job_uuid "$output")

    assert_line --index 2 "Proj_5678_F_2:${job_uuid}"
}

@test "should correctly handle -j (job UUID) parameter" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    input_filename="${TEST_TEMP_DIR}/test.yaml"
    echo "test input" > ${input_filename}

    # stub cwltoil to print the value of TOIL_LSF_PROJECT
    stub cwltoil 'printenv TOIL_LSF_PROJECT'

    pre_generated_job_uuid='836260e0-4af0-11e7-ab78-645106efb11c'

    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${input_filename} -b lsf -p Proj_5000_B -j ${pre_generated_job_uuid}

    assert_success

    # get job UUID
    job_uuid=$(get_job_uuid "$output")

    # check the content of job_uuid file
    assert_equal "${job_uuid}" `cat ./outputs/job-uuid`

    assert_equal "${pre_generated_job_uuid}" "${job_uuid}"

    assert_line --index 2 "Proj_5000_B:${pre_generated_job_uuid}"
}

@test "should exit with the correct exit code 0" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    input_filename="${TEST_TEMP_DIR}/test.yaml"
    echo "test input" > ${input_filename}

    # stub cwltoil to exit with code 0
    stub cwltoil 'exit 0'

    # call roslin-runner
    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${input_filename} -b lsf

    assert_success

    unstubs
}

@test "should exit with the correct exit code 1" {

    # load the Roslin Core settings
    source ./mock/roslin-core/1.0.0/config/settings.sh

    # load the Roslin Variant Pipeline settings
    export ROSLIN_DEFAULT_PIPELINE_NAME_VERSION="variant/1.0.0"

    # configure Singularity path
    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # create fake input file
    input_filename="${TEST_TEMP_DIR}/test.yaml"
    echo "test input" > ${input_filename}

    # stub cwltoil to exit with code 1
    stub cwltoil 'exit 1'

    # call roslin-runner
    run ${ROSLIN_RUNNER_SCRIPT} -w abc.cwl -i ${input_filename} -b lsf

    assert_failure

    unstubs
}
