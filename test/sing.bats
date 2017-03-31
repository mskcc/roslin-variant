#!/usr/bin/env bats

SING_SCRIPT="/vagrant/setup/bin/sing/sing.sh"

@test "should have sing.sh" {

    command -v ${SING_SCRIPT}
}

@test "should be able to run singularity" {

    command -v singularity
}

@test "should exit(1) if necessary PATHs are not configured" {

    unset PRISM_BIN_PATH
    unset PRISM_DATA_PATH
    unset PRISM_SINGULARITY_PATH

    run ${SING_SCRIPT}

    [ "$status" -eq 1 ]
}

@test "should exit(1) if the two required parameters are not supplied" {

    # mock paths
    export PRISM_BIN_PATH="a"
    export PRISM_DATA_PATH="b"
    export PRISM_SINGULARITY_PATH="c"
    
    run ${SING_SCRIPT}

    [ "$status" -eq 1 ]
}

@test "should run the tool image and display 'Hello, World!'" {

    # this will load PRISM_BIN_PATH and PRISM_DATA_PATH
    source ./settings.sh
    
    export PRISM_SINGULARITY_PATH=`which singularity`
    
    run ${SING_SCRIPT} fake-tool 1.0.0 "Hello, World!"

    [ "$status" -eq 0 ]
    [ "$output" == "Hello, World!" ]
}
