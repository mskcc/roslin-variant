if [ "$1" == "help" ]
then
	echo "Please use either pileup, concordance, contamination, merge"
	exit 1
fi
export PYTHONNOUSERSITE="set"
case $1 in
    pileup) shift; exec python /usr/bin/conpair/scripts/run_gatk_pileup_for_sample.py "$@" ;;
    concordance) shift; exec python /usr/bin/conpair/scripts/verify_concordances.py "$@" ;;
    contamination) shift; exec python /usr/bin/conpair/scripts/estimate_tumor_normal_contaminations.py "$@" ;;
    *) echo "Please use either pileup, concordance, contamination, merge"; exit 1 ;;
esac