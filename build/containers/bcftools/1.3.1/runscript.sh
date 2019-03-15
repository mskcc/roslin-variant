if [ "$1" = "help" ]
then
	exec /usr/bin/bcftools
fi
exec /usr/bin/bcftools "$@"