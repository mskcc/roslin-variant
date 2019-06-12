if [ "$1" = "help" ]
then
	echo "pindel or pindel2vcf?"
	exit 1
fi

export PYTHONNOUSERSITE="set"
unset LANG

case $1 in
    pindel) shift; exec /usr/bin/pindel "$@" ;;
    pindel2vcf) shift; exec /usr/bin/pindel2vcf "$@" ;;
    *) echo "pindel or pindel2vcf?"; exit 1 ;;
esac
