if [ "$1" = "help" ]
then
	exec /usr/bin/GetBaseCountsMultiSample
fi

export PYTHONNOUSERSITE="set"
unset LANG

exec /usr/bin/GetBaseCountsMultiSample "$@"