#!/usr/bin/env bats

load 'helpers/bats-support/load'
load 'helpers/bats-assert/load'
load 'helpers/bats-file/load'

SING_SCRIPT="/vagrant/setup/bin/sing/sing.sh"

@test "should have sing.sh" {

    assert_file_exist ${SING_SCRIPT}
}

@test "should be able to run singularity" {

    command -v singularity
}

@test "should abort if all the necessary env vars are not configured" {

    unset PRISM_BIN_PATH
    unset PRISM_DATA_PATH
    unset PRISM_SINGULARITY_PATH

    run ${SING_SCRIPT}

    assert_failure
    assert_line 'Some of the necessary paths are not correctly configured!'
}

@test "should abort if PRISM_SINGULARITY_PATH is not configured" {

    export PRISM_BIN_PATH="a"
    export PRISM_DATA_PATH="b"
    unset PRISM_SINGULARITY_PATH

    run ${SING_SCRIPT}

    assert_failure
    assert_line 'Some of the necessary paths are not correctly configured!'
}

@test "should abort if PRISM_DATA_PATH is not configured" {

    export PRISM_BIN_PATH="a"
    unset PRISM_DATA_PATH
    export PRISM_SINGULARITY_PATH="c"

    run ${SING_SCRIPT}

    assert_failure
    assert_line 'Some of the necessary paths are not correctly configured!'
}

@test "should abort if PRISM_BIN_PATH is not configured" {

    unset PRISM_BIN_PATH
    export PRISM_DATA_PATH="b"
    export PRISM_SINGULARITY_PATH="c"

    run ${SING_SCRIPT}

    assert_failure
    assert_line 'Some of the necessary paths are not correctly configured!'
}

@test "should abort if the two required parameters are not supplied" {

    # mock paths
    export PRISM_BIN_PATH="a"
    export PRISM_DATA_PATH="b"
    export PRISM_SINGULARITY_PATH="c"
    
    run ${SING_SCRIPT}

    assert_failure
    assert_line --index 0 --partial "Usage:"
}

@test "should run the tool image and display 'Hello, World!'" {

    # this will load PRISM_BIN_PATH and PRISM_DATA_PATH
    source ./settings.sh
    
    export PRISM_SINGULARITY_PATH=`which singularity`
    
    run ${SING_SCRIPT} fake-tool 1.0.0 "Hello, World!"

    assert_success

    # because of the way fake-tool is built,
    # if it runs correctly, it will echo out the arguments received
    assert_output "Hello, World!"
}
