if [ "$1" = "help" ]
then
	echo "pindel, mutect, vardict, sid, or complex?"
	exit 1
fi

export PYTHONNOUSERSITE="set"
case $1 in
    pindel) shift; exec python /usr/bin/basicfiltering/filter_pindel.py "$@" ;;
    mutect) shift; exec python /usr/bin/basicfiltering/filter_mutect.py "$@" ;;
    vardict) shift; exec python /usr/bin/basicfiltering/filter_vardict.py "$@" ;;
    sid) shift; exec python /usr/bin/basicfiltering/filter_sid.py "$@" ;;
    complex) shift; exec python /usr/bin/basicfiltering/filter_complex.py "$@" ;;
    *) echo "pindel, mutect, vardict, sid, or complex?"; exit 1 ;;
esac