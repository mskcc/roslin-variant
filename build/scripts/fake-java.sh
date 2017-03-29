#!/bin/bash
java_cmds=()
nonjava_cmds=()

flag=0
for var in "$@"
do

    if [ $flag -eq 0 ]
    then
        # we're handling java commands
        java_cmds+=("$var")
    else
        # we're handling non-java commands
        nonjava_cmds+=("$var")
    fi

    if [ "$var" == "-jar" ]
    then
        # we're done with handling java commands
        flag=1
    fi

done

#echo ${nonjava_cmds[*]}
exec ${nonjava_cmds[*]}
