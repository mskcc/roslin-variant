#!/usr/bin/env bats

BATS_TEST_DIRNAME="/vagrant/test/mock"
export PATH="$BATS_TEST_DIRNAME/stub:$PATH"

SING_SCRIPT="/vagrant/setup/bin/sing/sing.sh"
SING_JAVA_SCRIPT="/vagrant/setup/bin/sing/sing-java.sh"


stub() {
    if [ ! -d $BATS_TEST_DIRNAME/stub ]; then
        mkdir -p $BATS_TEST_DIRNAME/stub
    fi
    echo $2 > $BATS_TEST_DIRNAME/stub/$1
    chmod +x $BATS_TEST_DIRNAME/stub/$1
}
rm_stubs() {
    rm -rf $BATS_TEST_DIRNAME/stub
}

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

@test "should properly reconstruct the command2" {

    # this will load PRISM_BIN_PATH and PRISM_DATA_PATH
    source ./settings.sh
    
    export PRISM_SINGULARITY_PATH=`which singularity`

    java_opts="-Xms256m -Xmx30g -XX:-UseGCOverheadLimit -Djava.io.tmpdir=/scratch/ -jar"
    tool_opts="MarkDuplicates a b c d"

    stub sing.sh 'echo "sing.sh $@"'

    run ${SING_JAVA_SCRIPT} ${java_opts} \
        sing.sh fake-tool 1.0.0 ${tool_opts}

    [ "$status" -eq 0 ]

    # expect:
    # sing.sh fake-tool 1.0.0 -Xms256m -Xmx30g -XX:-UseGCOverheadLimit -Djava.io.tmpdir=/scratch/ -jar fake-tool MarkDuplicates a b c d
    [ "$output" == "sing.sh fake-tool 1.0.0 ${java_opts} fake-tool ${tool_opts}" ]

    rm_stubs
}
