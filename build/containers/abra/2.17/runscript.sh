if [ "$1" == "help" ]
then
	exec java /usr/bin/abra.jar
fi

exec java $1 /usr/bin/abra.jar $2