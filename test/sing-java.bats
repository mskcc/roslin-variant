#!/usr/bin/env bats

load 'helpers/bats-support/load'
load 'helpers/bats-assert/load'
load 'helpers/bats-file/load'
load 'helpers/stub/load'

SING_SCRIPT="/vagrant/setup/bin/sing/sing.sh"
SING_JAVA_SCRIPT="/vagrant/setup/bin/sing/sing-java.sh"

@test "should have sing.sh" {

    assert_file_exist ${SING_SCRIPT}
}

@test "should have sing-java.sh" {

    assert_file_exist ${SING_JAVA_SCRIPT}
}

@test "should properly reconstruct the command" {

    # this will load PRISM_BIN_PATH and PRISM_DATA_PATH
    source ./settings.sh
    
    export PRISM_SINGULARITY_PATH=`which singularity`

    java_opts="-Xms256m -Xmx30g -XX:-UseGCOverheadLimit -Djava.io.tmpdir=/scratch/ -jar"
    tool_opts="MarkDuplicates a b c d"

    run ${SING_JAVA_SCRIPT} ${java_opts} \
        ${SING_SCRIPT} fake-tool 1.0.0 ${tool_opts}

    assert_success

    # because of the way fake-tool is built,
    # if it runs correctly, it will echo out the arguments received
    assert_output "${java_opts} /usr/bin/fake-tool.jar ${tool_opts}"
}

@test "should properly construct the sing call for picard 1.129" {

    # this will load PRISM_BIN_PATH and PRISM_DATA_PATH
    source ./settings.sh
    
    export PRISM_SINGULARITY_PATH=`which singularity`

    java_opts="-Xms256m -Xmx30g -XX:-UseGCOverheadLimit -Djava.io.tmpdir=/scratch/ -jar"
    tool_name="picard"
    tool_version="1.129"
    tool_subcmd="MarkDuplicates"
    tool_opts="a b c d"

    # stub sing.sh to echo out "sing.sh" + all the rest of the arguments passed
    stub sing.sh 'echo "sing.sh $@"'

    run ${SING_JAVA_SCRIPT} ${java_opts} \
        sing.sh ${tool_name} ${tool_version} ${tool_subcmd} ${tool_opts}

    assert_success

    # expect:
    #
    # sing.sh picard 1.129 -Xms256m -Xmx30g -XX:-UseGCOverheadLimit -Djava.io.tmpdir=/scratch/ -jar /usr/bin/picard-tools/picard.jar MarkDuplicates a b c d
    #
    assert_output "sing.sh ${tool_name} ${tool_version} ${java_opts} /usr/bin/picard-tools/picard.jar ${tool_subcmd} ${tool_opts}"

    unstubs
}

@test "should properly construct the sing call for picard 1.96" {

    # this will load PRISM_BIN_PATH and PRISM_DATA_PATH
    source ./settings.sh
    
    export PRISM_SINGULARITY_PATH=`which singularity`

    java_opts="-Xms256m -Xmx30g -XX:-UseGCOverheadLimit -Djava.io.tmpdir=/scratch/ -jar"
    tool_name="picard"
    tool_version="1.96"
    tool_subcmd="MarkDuplicates"
    tool_opts="a b c d"

    # stub sing.sh to echo out "sing.sh" + all the rest of the arguments passed
    stub sing.sh 'echo "sing.sh $@"'

    run ${SING_JAVA_SCRIPT} ${java_opts} \
        sing.sh ${tool_name} ${tool_version} ${tool_subcmd} ${tool_opts}

    assert_success

    # expect:
    #
    # sing.sh picard 1.96 -Xms256m -Xmx30g -XX:-UseGCOverheadLimit -Djava.io.tmpdir=/scratch/ -jar /usr/bin/picard-tools/MarkDuplicates.jar a b c d
    #
    assert_output "sing.sh ${tool_name} ${tool_version} ${java_opts} /usr/bin/picard-tools/${tool_subcmd}.jar ${tool_opts}"

    unstubs
}

@test "should properly construct the sing call for abra 0.92" {

    # this will load PRISM_BIN_PATH and PRISM_DATA_PATH
    source ./settings.sh
    
    export PRISM_SINGULARITY_PATH=`which singularity`

    java_opts="-Xms256m -Xmx30g -XX:-UseGCOverheadLimit -Djava.io.tmpdir=/scratch/ -jar"
    tool_name="abra"
    tool_version="0.92"
    tool_opts="a b c d"

    # stub sing.sh to echo out "sing.sh" + all the rest of the arguments passed
    stub sing.sh 'echo "sing.sh $@"'

    run ${SING_JAVA_SCRIPT} ${java_opts} \
        sing.sh ${tool_name} ${tool_version} ${tool_opts}

    assert_success

    # expect:
    #
    # sing.sh abra 0.92 -Xms256m -Xmx30g -XX:-UseGCOverheadLimit -Djava.io.tmpdir=/scratch/ -jar /usr/bin/abra.jar a b c d
    #
    assert_output "sing.sh ${tool_name} ${tool_version} ${java_opts} /usr/bin/${tool_name}.jar ${tool_opts}"

    unstubs
}

@test "should properly construct the sing call for mutect 1.1.4" {

    # this will load PRISM_BIN_PATH and PRISM_DATA_PATH
    source ./settings.sh
    
    export PRISM_SINGULARITY_PATH=`which singularity`

    java_opts="-Xms256m -Xmx30g -XX:-UseGCOverheadLimit -Djava.io.tmpdir=/scratch/ -jar"
    tool_name="mutect"
    tool_version="1.1.4"
    tool_opts="a b c d"

    # stub sing.sh to echo out "sing.sh" + all the rest of the arguments passed
    stub sing.sh 'echo "sing.sh $@"'

    run ${SING_JAVA_SCRIPT} ${java_opts} \
        sing.sh ${tool_name} ${tool_version} ${tool_opts}

    assert_success

    # expect:
    #
    # sing.sh mutect 1.1.4 -Xms256m -Xmx30g -XX:-UseGCOverheadLimit -Djava.io.tmpdir=/scratch/ -jar /usr/bin/mutect.jar a b c d
    #
    assert_output "sing.sh ${tool_name} ${tool_version} ${java_opts} /usr/bin/${tool_name}.jar ${tool_opts}"

    unstubs
}
