if [ "$1" = "help" ]
then
	exec /usr/bin/trim_galore --help
fi

export PYTHONNOUSERSITE="set"

exec /usr/bin/trim_galore "$@"