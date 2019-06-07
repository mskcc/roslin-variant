if [ "$1" = "help" ]
then
	exec /usr/bin/samtools "$@"
fi

export PYTHONNOUSERSITE="set"

exec /usr/bin/samtools "$@"