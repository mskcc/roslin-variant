# set resources for cmo
export CMO_RESOURCE_CONFIG=/etc/conf.d/basic-filtering-resources.json

if [ "$1" = "help" ]
then
	echo "pindel, mutect, vardict, or sid?"
	exit 1
fi

export PYTHONNOUSERSITE="set"
case $1 in
    pindel) shift; exec python /usr/bin/basicfiltering/filter_pindel.py "$@" ;;
    mutect) shift; exec python /usr/bin/basicfiltering/filter_mutect.py "$@" ;;
    vardict) shift; exec python /usr/bin/basicfiltering/filter_vardict.py "$@" ;;
    sid) shift; exec python /usr/bin/basicfiltering/filter_sid.py "$@" ;;
    *) echo "pindel, mutect, vardict, or sid?"; exit 1 ;;
esac