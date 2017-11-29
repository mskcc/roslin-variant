#!/bin/bash

# sing-java.sh \
#   -Xms256m -Xmx30g -XX:-UseGCOverheadLimit -Djava.io.tmpdir=/scratch/ \
#   -jar \
#   sing.sh picard 1.129 MarkDuplicates a b c d

java_opts=()
sing_opts=()

flag=0
for var in $@
do

    if [ $flag -eq 0 ]
    then
        # we're handling java options
        java_opts+=("$var")
    else
        # we're handling tool options
        sing_opts+=("$var")
    fi

    if [ "$var" == "-jar" ] || [ "$var" == "-cp" ]
    then
        # we're done with handling java options
        flag=1
    fi

done

# echo ${java_opts[*]}
# -Xms256m -Xmx30g -XX:-UseGCOverheadLimit -Djava.io.tmpdir=/scratch/ -jar

# echo ${sing_opts[*]}
# sing.sh picard 1.129 MarkDuplicates a b c d

tool_name=${sing_opts[1]}
tool_version=${sing_opts[2]}
tool_opts=`echo ${sing_opts[*]} | cut -d' ' -f4-`

# override $tool_name and/or $tool_opts 
case $tool_name in

    picard)
        case $tool_version in
            1.96)
                tool_name="/usr/bin/picard-tools/${sing_opts[3]}.jar" ;;
            *)
                tool_name="/usr/bin/picard-tools/picard.jar ${sing_opts[3]}" ;;
        esac
        tool_opts=`echo ${sing_opts[*]} | cut -d' ' -f5-`
        ;;

    abra)
        tool_name="/usr/bin/abra.jar"
        tool_opts=`echo ${sing_opts[*]} | cut -d' ' -f4-`
        ;;

	marianas)
        tool_name="/usr/bin/marianas-0.0.0.jar"
        tool_opts=`echo ${sing_opts[*]} | cut -d' ' -f4-`
        ;;

    *)
        tool_name="/usr/bin/${tool_name}.jar"
        tool_opts=`echo ${sing_opts[*]} | cut -d' ' -f4-`
        ;;

esac

sing=`echo ${sing_opts[*]} | cut -d' ' -f1-3`

# echo "==> $sing ${java_opts[*]} ${tool_name} ${tool_opts}"
$sing ${java_opts[*]} ${tool_name} ${tool_opts}
