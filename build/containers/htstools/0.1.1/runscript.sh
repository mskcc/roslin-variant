if [ "$1" = "help" ]
then
	echo "Please use either snp-pileup or ppflag-fixer"
	exit 1
fi

export PYTHONNOUSERSITE="set"
case $1 in
    snp-pileup) shift; exec /usr/bin/snp-pileup "$@" ;;
    ppflag-fixer) shift; exec /usr/bin/ppflag-fixer "$@" ;;
    *) echo "Please use either snp-pileup or ppflag-fixer"; exit 1 ;;
esac