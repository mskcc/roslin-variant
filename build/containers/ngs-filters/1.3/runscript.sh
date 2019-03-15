if [ "$1" = "help" ]
then
	exec python /usr/bin/ngs-filters/run_ngs-filters.py --help
fi

export PYTHONNOUSERSITE="set"
exec python /usr/bin/ngs-filters/run_ngs-filters.py "$@"