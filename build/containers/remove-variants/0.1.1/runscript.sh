if [ "$1" = "help" ]
then
	exec python /usr/bin/remove_variants.py --help
fi

export PYTHONNOUSERSITE="set"
exec python /usr/bin/remove_variants.py "$@"