if [ "$1" == "help" ]
then
	exec java /usr/bin/mutect.jar --help
fi

exec java $1 /usr/bin/mutect.jar ${@:2}