#!/usr/bin/env bats

SING_SCRIPT="/vagrant/setup/bin/sing/sing.sh"
SING_JAVA_SCRIPT="/vagrant/setup/bin/sing/sing-java.sh"

@test "should have sing.sh" {

    command -v ${SING_SCRIPT}
}

@test "should have sing-java.sh" {

    command -v ${SING_JAVA_SCRIPT}
}

@test "should properly reconstruct the command" {

    # this will load PRISM_BIN_PATH and PRISM_DATA_PATH
    source ./settings.sh
    
    export PRISM_SINGULARITY_PATH=`which singularity`

    java_opts="-Xms256m -Xmx30g -XX:-UseGCOverheadLimit -Djava.io.tmpdir=/scratch/ -jar"
    tool_opts="MarkDuplicates a b c d"

    run ${SING_JAVA_SCRIPT} ${java_opts} \
        ${SING_SCRIPT} fake-tool 1.0.0 ${tool_opts}

    [ "$status" -eq 0 ]

    # because of the way fake-tool is built,
    # if it runs correctly, it will echo out the arguments received
    [ "$output" == "${java_opts} fake-tool ${tool_opts}" ]
}
