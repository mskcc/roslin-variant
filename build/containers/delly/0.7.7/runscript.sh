if [ "$1" = "help" ]
then
	exec /usr/local/bin/delly
fi
export PYTHONNOUSERSITE="set"

exec /usr/local/bin/delly "$@"