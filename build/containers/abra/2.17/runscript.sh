if [ "$1" == "help" ]
then
	exec java -jar /usr/bin/abra.jar
fi

java_args=$1
shift
exec java $java_args /usr/bin/abra.jar $@