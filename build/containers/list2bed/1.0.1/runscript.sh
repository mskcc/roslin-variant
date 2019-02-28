if [ "$1" == "help" ]
then
	exec python /usr/bin/list2bed.py
fi

export PYTHONNOUSERSITE="set"
exec python /usr/bin/list2bed.py "$@"