if [ "$1" == "help" ]
then
	exec java -jar /usr/bin/picard-tools/picard.jar
fi

java_args=$1
shift
exec java $java_args /usr/bin/picard-tools/picard.jar $@