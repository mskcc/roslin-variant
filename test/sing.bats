#!/usr/bin/env bats

load 'helpers/bats-support/load'
load 'helpers/bats-assert/load'
load 'helpers/bats-file/load'

SING_SCRIPT="/vagrant/core/bin/sing/sing.sh"

@test "should have sing.sh" {

    assert_file_exist ${SING_SCRIPT}
}

@test "should be able to run singularity" {

    command -v singularity
}

@test "should abort if all the necessary env vars are not configured" {

    unset ROSLIN_PIPELINE_BIN_PATH
    unset ROSLIN_PIPELINE_DATA_PATH
    unset ROSLIN_PIPELINE_WORKSPACE_PATH
    unset ROSLIN_PIPELINE_OUTPUT_PATH
    unset ROSLIN_EXTRA_BIND_PATH
    unset ROSLIN_SINGULARITY_PATH

    run ${SING_SCRIPT}

    assert_failure
    assert_line 'Some of the necessary paths are not correctly configured!'
}

@test "should abort if ROSLIN_PIPELINE_BIN_PATH is not configured" {

    unset ROSLIN_PIPELINE_BIN_PATH
    export ROSLIN_PIPELINE_DATA_PATH="b"
    export ROSLIN_PIPELINE_WORKSPACE_PATH="c"
    export ROSLIN_OUPUT_PATH="d"
    export ROSLIN_EXTRA_BIND_PATH="e"
    export ROSLIN_SINGULARITY_PATH="f"

    run ${SING_SCRIPT}

    assert_failure
    assert_line 'Some of the necessary paths are not correctly configured!'
}

@test "should abort if ROSLIN_PIPELINE_DATA_PATH is not configured" {

    export ROSLIN_PIPELINE_BIN_PATH="a"
    unset ROSLIN_PIPELINE_DATA_PATH
    export ROSLIN_PIPELINE_WORKSPACE_PATH="c"
    export ROSLIN_OUPUT_PATH="d"
    export ROSLIN_EXTRA_BIND_PATH="e"
    export ROSLIN_SINGULARITY_PATH="f"

    run ${SING_SCRIPT}

    assert_failure
    assert_line 'Some of the necessary paths are not correctly configured!'
}

@test "should abort if ROSLIN_PIPELINE_WORKSPACE_PATH is not configured" {

    export ROSLIN_PIPELINE_BIN_PATH="a"
    export ROSLIN_PIPELINE_DATA_PATH="b"
    unset ROSLIN_PIPELINE_WORKSPACE_PATH
    export ROSLIN_OUPUT_PATH="d"
    export ROSLIN_EXTRA_BIND_PATH="e"
    export ROSLIN_SINGULARITY_PATH="f"

    run ${SING_SCRIPT}

    assert_failure
    assert_line 'Some of the necessary paths are not correctly configured!'
}

@test "should abort if ROSLIN_OUPUT_PATH is not configured" {

    export ROSLIN_PIPELINE_BIN_PATH="a"
    export ROSLIN_PIPELINE_DATA_PATH="b"
    export ROSLIN_PIPELINE_WORKSPACE_PATH="c"
    unset ROSLIN_OUPUT_PATH
    export ROSLIN_EXTRA_BIND_PATH="e"
    export ROSLIN_SINGULARITY_PATH="f"

    run ${SING_SCRIPT}

    assert_failure
    assert_line 'Some of the necessary paths are not correctly configured!'
}

@test "should abort if ROSLIN_EXTRA_BIND_PATH is not configured" {

    export ROSLIN_PIPELINE_BIN_PATH="a"
    export ROSLIN_PIPELINE_DATA_PATH="b"
    export ROSLIN_PIPELINE_WORKSPACE_PATH="c"
    export ROSLIN_OUPUT_PATH="d"
    unset ROSLIN_EXTRA_BIND_PATH
    export ROSLIN_SINGULARITY_PATH="f"

    run ${SING_SCRIPT}

    assert_failure
    assert_line 'Some of the necessary paths are not correctly configured!'
}

@test "should abort if ROSLIN_SINGULARITY_PATH is not configured" {

    export ROSLIN_PIPELINE_BIN_PATH="a"
    export ROSLIN_PIPELINE_DATA_PATH="b"
    export ROSLIN_PIPELINE_WORKSPACE_PATH="c"
    export ROSLIN_OUPUT_PATH="d"
    export ROSLIN_EXTRA_BIND_PATH="e"
    unset ROSLIN_SINGULARITY_PATH

    run ${SING_SCRIPT}

    assert_failure
    assert_line 'Some of the necessary paths are not correctly configured!'
}

@test "should abort if the two required parameters are not supplied" {

    # load the Roslin Pipeline settings
    source ./mock/roslin-core/1.0.0/config/variant/1.0.0/settings.sh

    export ROSLIN_SINGULARITY_PATH=`which singularity`

    run ${SING_SCRIPT}

    assert_failure
    assert_line --index 0 --partial "Usage:"
}

@test "should run the tool image and display 'Hello, World!'" {

    # load the Roslin Pipeline settings
    source ./mock/roslin-core/1.0.0/config/variant/1.0.0/settings.sh

    export ROSLIN_SINGULARITY_PATH=`which singularity`

    run ${SING_SCRIPT} fake-tool 1.0.0 "Hello, World!"

    assert_success

    # because of the way fake-tool is built,
    # if it runs correctly, it will echo out the arguments received
    assert_output "Hello, World!"
}

@test "should properly bind all the paths defined" {

    # load the Roslin Pipeline settings
    source ./mock/roslin-core/1.0.0/config/variant/1.0.0/settings.sh

    # fake singularity so that it just echoed out the arguments received
    export ROSLIN_SINGULARITY_PATH="echo"

    run ${SING_SCRIPT} fake-tool 1.0.0

    assert_success

    # because of the way fake-tool is built,
    # if it runs correctly, it will echo out the arguments received
    bind_extra=""
    for extra_path in ${ROSLIN_EXTRA_BIND_PATH}
    do
        bind_extra="${bind_extra} --bind ${extra_path}:${extra_path}"
    done
    assert_output "run --bind ${ROSLIN_PIPELINE_BIN_PATH}:${ROSLIN_PIPELINE_BIN_PATH} --bind ${ROSLIN_PIPELINE_DATA_PATH}:${ROSLIN_PIPELINE_DATA_PATH} --bind ${ROSLIN_PIPELINE_WORKSPACE_PATH}:${ROSLIN_PIPELINE_WORKSPACE_PATH} --bind ${ROSLIN_PIPELINE_OUTPUT_PATH}:${ROSLIN_PIPELINE_OUTPUT_PATH}${bind_extra} ${PWD}/mock/roslin-pipelines/variant/1.0.0/bin/img/fake-tool/1.0.0/fake-tool.img"
}

@test "should call singularity with env -i" {

    # load the Roslin Pipeline settings
    source ./mock/roslin-core/1.0.0/config/variant/1.0.0/settings.sh

    export ROSLIN_SINGULARITY_PATH=`which singularity`

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

@test "should return metadata (labels) if -i (inspect) option is supplied" {

    # load the Roslin Pipeline settings
    source ./mock/roslin-core/1.0.0/config/variant/1.0.0/settings.sh

    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # fake-tool has metadata
    run ${SING_SCRIPT} -i fake-tool 1.0.0 "Hello, World!"

    assert_success

    assert_output '{
  "maintainer": "Jaeyoung Chun (chunj@mskcc.org)",
  "source.trimgalore": "http://mskcc.org/",
  "version.alpine": "3.5.x",
  "version.container": "1.0.0",
  "version.fake-tool": "1.0.1"
}'
}

@test "should return non-zero exit code if metadata is not found" {

    # load the Roslin Pipeline settings
    source ./mock/roslin-core/1.0.0/config/variant/1.0.0/settings.sh

    export ROSLIN_SINGULARITY_PATH=`which singularity`

    # env-tool does not have metadata
    run ${SING_SCRIPT} -i env-tool 1.0.0 "Hello, World!"

    assert_failure
}
