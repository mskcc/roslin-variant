#!/bin/bash

# sing-java.sh \
#   -Xms256m -Xmx30g -XX:-UseGCOverheadLimit -Djava.io.tmpdir=/scratch/ \
#   -jar \
#   sing.sh picard 1.129 MarkDuplicates a b c d

java_opts=()
sing_opts=()

flag=0
for var in "$@"
do

    if [ $flag -eq 0 ]
    then
        # we're handling java options
        java_opts+=("$var")
    else
        # we're handling tool options
        sing_opts+=("$var")
    fi

    if [ "$var" == "-jar" ]
    then
        # we're done with handling java options
        flag=1
    fi

done

# -Xms256m -Xmx30g -XX:-UseGCOverheadLimit -Djava.io.tmpdir=/scratch/ -jar
# echo ${java_opts[*]}

# sing.sh picard 1.129 MarkDuplicates a b c d
# echo ${sing_opts[*]}

tool_name=${sing_opts[1]}
tool_version=${sing_opts[2]}
# echo "$0 $@"

if [ "$tool_name" == "picard" ]
then
    if [ "$tool_version" == "1.96" ]
    then
        tool_name="/usr/bin/picard-tools/${sing_opts[3]}.jar"
    else
        tool_name="/usr/bin/picard-tools/picard.jar ${sing_opts[3]}"
    fi
fi

sing=`echo ${sing_opts[*]} | cut -d' ' -f1-3`
tool_opts=`echo ${sing_opts[*]} | cut -d' ' -f5-`

# echo "==> $sing ${java_opts[*]} ${tool_name} ${tool_opts}"
$sing ${java_opts[*]} ${tool_name} ${tool_opts}
