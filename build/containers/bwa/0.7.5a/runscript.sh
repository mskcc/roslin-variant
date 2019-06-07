if [ "$1" = "help" ]
then
	exec /usr/bin/bwa
fi

export PYTHONNOUSERSITE="set"

exec /usr/bin/bwa "$@"