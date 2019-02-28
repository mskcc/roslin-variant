if [ "$1" == "help" ]
then
	exec java /usr/bin/gatk.jar --help
fi

exec java $1 /usr/bin/gatk.jar $2