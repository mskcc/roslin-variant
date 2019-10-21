if [ "$1" = "help" ]
then
	exec java -jar  /usr/bin/gatk.jar
fi

java_opts=""
tool_opts=""
export PYTHONNOUSERSITE="set"
unset LANG

flag=0
for var in $@
do

    if [ $flag -eq 0 ]
    then
        # we're handling java options
        java_opts="$java_opts $var"
    else
        # we're handling tool options
        tool_opts="$tool_opts $var"
    fi

    if [ "$var" = "-jar" ]
    then
        # we're done with handling java options
        flag=1
    fi

done

exec java $java_opts /usr/bin/gatk.jar $tool_opts