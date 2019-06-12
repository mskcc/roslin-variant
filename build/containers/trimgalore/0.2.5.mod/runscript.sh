if [ "$1" = "help" ]
then
	exec /usr/bin/trim_galore --help
fi

export PYTHONNOUSERSITE="set"
unset LANG

exec /usr/bin/trim_galore "$@"