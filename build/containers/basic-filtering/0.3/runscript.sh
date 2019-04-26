
export CMO_RESOURCE_CONFIG=/usr/bin/basicfiltering/data/cmo_resources.json

if [ "$1" = "help" ]
then
	echo "mutect, vardict, or complex?"
	exit 1
fi

export PYTHONNOUSERSITE="set"
case $1 in
    mutect) shift; exec python /usr/bin/basicfiltering/filter_mutect.py "$@" ;;
    vardict) shift; exec python /usr/bin/basicfiltering/filter_vardict.py "$@" ;;
    complex) shift; exec python /usr/bin/basicfiltering/filter_complex.py "$@" ;;
    *) echo "mutect, vardict, or complex?"; exit 1 ;;
esac