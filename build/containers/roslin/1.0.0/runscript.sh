if [ "$1" = "help" ]
then
	exec cat /welcome.txt
fi

export PYTHONNOUSERSITE="set"
unset LANG

exec cat /welcome.txt
