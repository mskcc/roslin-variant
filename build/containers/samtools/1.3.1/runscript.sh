if [ "$1" = "help" ]
then
	exec /usr/bin/samtools "$@"
fi

exec /usr/bin/samtools "$@"