if [ "$1" = "help" ]
then
	exec /usr/bin/samtools "$@"
fi

export PYTHONNOUSERSITE="set"
unset LANG
exec /usr/bin/samtools "$@"