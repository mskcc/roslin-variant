if [ "$1" = "help" ]
then
	exec /usr/bin/GetBaseCountsMultiSample
fi

export PYTHONNOUSERSITE="set"

exec /usr/bin/GetBaseCountsMultiSample "$@"