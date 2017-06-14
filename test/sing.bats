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
    unset PRISM_EXTRA_BIND_PATH

    run ${SING_SCRIPT}

    assert_failure
    assert_line 'Some of the necessary paths are not correctly configured!'
}

@test "should abort if PRISM_SINGULARITY_PATH is not configured" {

    export PRISM_BIN_PATH="a"
    export PRISM_DATA_PATH="b"
    export PRISM_EXTRA_BIND_PATH="c"
    unset PRISM_SINGULARITY_PATH

    run ${SING_SCRIPT}

    assert_failure
    assert_line 'Some of the necessary paths are not correctly configured!'
}

@test "should abort if PRISM_DATA_PATH is not configured" {

    export PRISM_BIN_PATH="a"
    unset PRISM_DATA_PATH
    export PRISM_EXTRA_BIND_PATH="c"
    export PRISM_SINGULARITY_PATH="d"

    run ${SING_SCRIPT}

    assert_failure
    assert_line 'Some of the necessary paths are not correctly configured!'
}

@test "should abort if PRISM_BIN_PATH is not configured" {

    unset PRISM_BIN_PATH
    export PRISM_DATA_PATH="b"
    export PRISM_EXTRA_BIND_PATH="c"
    export PRISM_SINGULARITY_PATH="d"

    run ${SING_SCRIPT}

    assert_failure
    assert_line 'Some of the necessary paths are not correctly configured!'
}

@test "should abort if PRISM_EXTRA_BIND_PATH is not configured" {

    export PRISM_BIN_PATH="a"
    export PRISM_DATA_PATH="b"
    unset PRISM_EXTRA_BIND_PATH
    export PRISM_SINGULARITY_PATH="d"

    run ${SING_SCRIPT}

    assert_failure
    assert_line 'Some of the necessary paths are not correctly configured!'
}

@test "should abort if the two required parameters are not supplied" {

    # mock paths
    export PRISM_BIN_PATH="a"
    export PRISM_DATA_PATH="b"
    export PRISM_EXTRA_BIND_PATH="c"
    export PRISM_SINGULARITY_PATH="d"

    run ${SING_SCRIPT}

    assert_failure
    assert_line --index 0 --partial "Usage:"
}

@test "should run the tool image and display 'Hello, World!'" {

    # this will load PRISM_BIN_PATH, PRISM_DATA_PATH, and PRISM_EXTRA_BIND_PATH
    source ./settings.sh

    export PRISM_SINGULARITY_PATH=`which singularity`

    run ${SING_SCRIPT} fake-tool 1.0.0 "Hello, World!"

    assert_success

    # because of the way fake-tool is built,
    # if it runs correctly, it will echo out the arguments received
    assert_output "Hello, World!"
}

@test "should properly bind extra paths defined" {

    # this will load PRISM_BIN_PATH, PRISM_DATA_PATH, and PRISM_EXTRA_BIND_PATH
    source ./settings.sh

    # fake singularity so that it just echoed out the arguments received
    export PRISM_SINGULARITY_PATH="echo"

    run ${SING_SCRIPT} fake-tool 1.0.0

    assert_success

    # because of the way fake-tool is built,
    # if it runs correctly, it will echo out the arguments received
    bind_extra=""
    for extra_path in ${PRISM_EXTRA_BIND_PATH}
    do
        bind_extra="${bind_extra} --bind ${extra_path}:${extra_path}"
    done
    assert_output "run --bind ${PRISM_BIN_PATH}:${PRISM_BIN_PATH} --bind ${PRISM_DATA_PATH}:${PRISM_DATA_PATH}${bind_extra} ${PWD}/mock/bin/tools/fake-tool/1.0.0/fake-tool.img"
}

@test "should call singularity with env -i" {

    # this will load PRISM_BIN_PATH, PRISM_DATA_PATH, and PRISM_EXTRA_BIND_PATH
    source ./settings.sh

    export PRISM_SINGULARITY_PATH=`which singularity`

    export UNIT_TEST_DONT_PASS_THIS_ENV="Hello, World!"

    run bash -c "${SING_SCRIPT} env-tool 1.0.0 | grep UNIT_TEST_DONT_PASS_THIS_ENV"

    # because grep should fail
    assert_failure

    # because of the way env-tool is built,
    # if it runs correctly, it will print out the environment being seen from inside the container
    # because of env -i, we should not see the environment variable we set prior to call sing.sh
    assert_output ""

    unset UNIT_TEST_DONT_PASS_THIS_ENV
}
