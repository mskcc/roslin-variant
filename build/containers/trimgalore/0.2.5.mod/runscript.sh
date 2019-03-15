if [ "$1" = "help" ]
then
	exec /usr/bin/trim_galore --help
fi

exec /usr/bin/trim_galore "$@"