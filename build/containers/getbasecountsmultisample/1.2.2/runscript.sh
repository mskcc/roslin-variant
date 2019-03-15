if [ "$1" = "help" ]
then
	exec /usr/bin/GetBaseCountsMultiSample
fi

exec /usr/bin/GetBaseCountsMultiSample "$@"