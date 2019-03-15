if [ "$1" = "help" ]
then
	exec /usr/bin/bwa
fi
exec /usr/bin/bwa "$@"