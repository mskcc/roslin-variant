if [ "$1" == "help" ]
then
	exec java /usr/bin/picard-tools/picard.jar
fi

exec java $1 /usr/bin/picard-tools/picard.jar ${@:2}