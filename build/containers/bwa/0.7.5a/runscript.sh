if [ "$1" = "help" ]
then
	exec /usr/bin/bwa
fi

export PYTHONNOUSERSITE="set"
unset LANG

exec /usr/bin/bwa "$@"