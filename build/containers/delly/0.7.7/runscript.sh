if [ "$1" = "help" ]
then
	exec /usr/local/bin/delly
fi
export PYTHONNOUSERSITE="set"
unset LANG

exec /usr/local/bin/delly "$@"