if [ "$1" = "help" ]
then
	exec cat /welcome.txt
fi

export PYTHONNOUSERSITE="set"

exec cat /welcome.txt
