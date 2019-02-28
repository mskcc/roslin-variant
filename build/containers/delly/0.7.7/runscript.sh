if [ "$1" == "help" ]
then
	exec /usr/local/bin/delly
fi
exec /usr/local/bin/delly "$@"